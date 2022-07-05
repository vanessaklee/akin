defmodule Akin do
  @moduledoc """
  Akin
  =======

  Functions for comparing two strings for similarity using a collection of string comparison algorithms for Elixir. Algorithms can be called independently or in total to return a map of metrics.

  ## Options

  Options accepted in a keyword list (i.e. [ngram_size: 3]).

  1. `algorithms`: algorithms to use in comparision. Accepts the name or a keyword list. Default is algorithms/0.
      1. `metric` - algorithm metric. Default is both
        - "string": uses string algorithms
        - "phonetic": uses phonetic algorithms
      1. `unit` - algorithm unit. Default is both.
        - "whole": uses algorithms best suited for whole string comparison (distance)
        - "partial": uses algorithms best suited for partial string comparison (substring)
  1. `level` - level for double phonetic matching. Default is "normal".
      - "strict": both encodings for each string must match
      - "strong": the primary encoding for each string must match
      - "normal": the primary encoding of one string must match either encoding of other string (default)
      - "weak":   either primary or secondary encoding of one string must match one encoding of other string
  1. `match_at`: an algorith score equal to or above this value is condsidered a match. Default is 0.9
  1. `ngram_size`: number of contiguous letters to split strings into. Default is 2.
  1. `short_length`: qualifies as "short" to recieve a shortness boost. Used by Name Metric. Default is 8.
  1. `stem`: boolean representing whether to compare the stemmed version the strings; uses Stemmer. Default `false`
  """
  import Akin.Util,
    only: [list_algorithms: 1, modulize: 1, compose: 1, opts: 2, r: 1, default_opts: 0]

  alias Akin.Corpus
  alias Akin.Names

  @spec compare(binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: float()
  @doc """
  Compare two strings. Return map of algorithm metrics.

  Options accepted as a keyword list. If no options are given, default values will be used.
  """
  def compare(left, right, opts \\ default_opts())

  def compare(left, right, opts) when is_binary(left) and is_binary(right) do
    if opts(opts, :stem) do
      left = compose(left).stems |> Enum.join(" ")
      right = compose(right).stems |> Enum.join(" ")
      compare(compose(left), compose(right), opts)
    else
      compare(compose(left), compose(right), opts)
    end
  end

  def compare(%Corpus{} = left, %Corpus{} = right, opts) do
    Enum.reduce(list_algorithms(opts), %{}, fn algorithm, acc ->
      score = apply(modulize(algorithm), :compare, [left, right, opts])

      if is_nil(score) do
        acc
      else
        Map.put(acc, String.to_atom(algorithm), r(score))
      end
    end)
  end

  @spec match_names(binary() | %Corpus{}, binary() | %Corpus{} | list(), keyword()) :: float()
  @doc """
  Compare a string against a list of strings.  Matches are determined by algorithem metrics equal to or higher than the
  `match_at` option. Return a list of strings that are a likely match.
  """
  def match_names(left, rights, opts \\ default_opts())

  def match_names(_, [], _), do: []

  def match_names(left, rights, opts) when is_binary(left) and is_list(rights) do
    rights = Enum.map(rights, fn right -> compose(right) end)
    match_names(compose(left), rights, opts)
  end

  def match_names(%Corpus{} = left, rights, opts) do
    Enum.reduce(rights, [], fn right, acc ->
      %{scores: scores} = Names.compare(left, right, opts)
      if Enum.any?(scores, fn {_algo, score} -> score > opts(opts, :match_at) end) do
        [right.original | acc]
      else
        acc
      end
    end)
  end

  @spec match_names_metrics(binary(), list(), keyword()) :: float()
  @doc """
  Compare a string against a list of strings. Matches are determined by algorithem metrics equal to or higher than the
  `match_at` option. Return a list of strings that are a likely match and their algorithm metrics.
  """
  def match_names_metrics(left, rights, opts \\ default_opts())

  def match_names_metrics(left, rights, opts) when is_binary(left) and is_list(rights) do
    Enum.reduce(rights, [], fn right, acc ->
      %{left: left, right: right, metrics: scores, match: match} =
        match_name_metrics(left, right, opts)

      if match == 1 do
        [%{left: left, right: right, metrics: scores, match: 1} | acc]
      else
        [%{left: left, right: right, metrics: scores, match: 0} | acc]
      end
    end)
  end

  @spec match_name_metrics(binary(), binary(), Keyword.t()) :: %{
          :left => binary(),
          :match => 0 | 1,
          :metrics => [any()],
          :right => binary()
        }
  @doc """
  Compare a string to a string with logic specific to names. Matches are determined by algorithem
  metrics equal to or higher than the `match_at` option. Return a list of strings that are a likely
  match and their algorithm metrics.
  """
  def match_name_metrics(left, rights, opts \\ default_opts())

  def match_name_metrics(left, right, opts) when is_binary(left) and is_binary(right) do
    left = compose(left)
    right = compose(right)

    %{scores: scores} = Names.compare(left, right, opts)
    left = Enum.join(left.list, " ")
    right = Enum.join(right.list, " ")

    if Enum.any?(scores, fn {_algo, score} -> score > opts(opts, :match_at) end) do
      %{left: left, right: right, metrics: scores, match: 1}
    else
      %{left: left, right: right, metrics: scores, match: 0}
    end
  end

  @spec phonemes(binary() | %Corpus{}) :: list()
  @doc """
  Returns list of unique phonetic encodings produces by the single and
  double metaphone algorithms.
  """
  def phonemes(string) when is_binary(string) do
    phonemes(compose(string), string)
  end

  defp phonemes(%Corpus{string: string}, _original_string) do
    single = Akin.Metaphone.Single.compute(string)
    double = Akin.Metaphone.Double.parse(string) |> Tuple.to_list()

    [single | double]
    |> List.flatten()
    |> Enum.uniq()
  end
end
