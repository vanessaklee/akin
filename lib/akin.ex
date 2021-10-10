defmodule Akin do
  @moduledoc """
  Compare two strings for similarity. Options accepted in a keyword list (i.e. [ngram_size: 3]).

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
    only: [list_algorithms: 0, list_algorithms: 1, modulize: 1, compose: 1, opts: 2]

  alias Akin.Corpus
  alias Akin.Names

  NimbleCSV.define(CSVParse, separator: "\t")

  @opts [ngram_size: 2, level: "normal", short_length: 8, match_at: 0.9]

  @spec compare(binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: float()
  @doc """
  Compare two strings. Return map of algorithm metrics.

  Options accepted as a keyword list. If no options are given, default values will be used.
  """
  def compare(left, right, opts \\ @opts)

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
    Enum.reduce(algorithms(opts), %{}, fn algorithm, acc ->
      Map.put(acc, algorithm, apply(modulize(algorithm), :compare, [left, right, opts]))
    end)
    |> Enum.reduce([], fn {k, v}, acc ->
      if is_nil(v) do
        acc
      else
        [{String.replace(k, ".", ""), v} | acc]
      end
    end)
    |> Enum.map(fn {k, v} -> {String.to_atom(k), r(v)} end)
    |> Enum.into(%{})
  end

  @spec compare_using(binary(), binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: float()
  @doc """
  Compare two strings using a particular algorithm. Return a map of metrics. The algorithm
  name must be an atom (i.e. "jaro_winkler").

  Options accepted as a keyword list. If no options are given, the default values will be used.
  """
  def compare_using(algorithm, left, right, opts \\ @opts)

  def compare_using(algorithm, left, right, opts) when is_binary(left) and is_binary(right) do
    compare_using(algorithm, compose(left), compose(right), opts)
  end

  def compare_using(algorithm, %Corpus{} = left, %Corpus{} = right, opts) do
    apply(modulize(algorithm), :compare, [left, right, opts]) |> Float.round(2)
  end

  @spec max(map()) :: float()
  @spec max(binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: list()
  @doc """
  Compare two strings. Return only the highest algorithm metrics. Options accepted as a keyword list.
  """
  def max(%{} = scores) do
    {_k, max_val} = Enum.max_by(scores, fn {_k, v} -> v end)
    Enum.filter(scores, fn {_k, v} -> v == max_val end)
  end

  def max(left, right, opts \\ @opts) do
    compare(left, right, opts)
    |> max()
  end

  @spec match_names(binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: float()
  @doc """
  Compare a string against a list of strings.  Matches are determined by algorithem metrics equal to or higher than the
  `match_at` option. Return a list of strings that are a likely match.
  """
  def match_names(left, rights, opts \\ @opts)

  def match_names(left, rights, opts) when is_binary(left) and is_list(rights) do
    rights = Enum.map(rights, fn right -> compose(right) end)
    match_names(compose(left), rights, opts)
  end

  def match_names(%Corpus{} = left, rights, opts) do
    Enum.reduce(rights, [], fn right, acc ->
      case Names.compare(left, right, opts) do
        %{scores: scores} ->
          if Enum.any?(scores, fn {_algo, score} -> score > opts(opts, :match_at) end) do
            [right.original | acc]
          else
            acc
          end

        _ ->
          acc
      end
    end)
  end

  @spec match_names_metrics(binary(), list(), keyword()) :: float()
  @doc """
  Compare a string against a list of strings. Matches are determined by algorithem metrics equal to or higher than the
  `match_at` option. Return a list of strings that are a likely match and their algorithm metrics.
  """
  def match_names_metrics(left, rights, opts \\ @opts)

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

  @spec match_name_metrics(binary(), binary(), keyword()) :: float()
  @doc """
  Compare a string to a string with logic specific to names. Matches are determined by algorithem
  metrics equal to or higher than the `match_at` option. Return a list of strings that are a likely
  match and their algorithm metrics.
  """
  def match_name_metrics(left, rights, opts \\ @opts)

  def match_name_metrics(left, right, opts) when is_binary(left) and is_binary(right) do
    left = compose(left)
    right = compose(right)

    case Names.compare(left, right, opts) do
      %{scores: scores} ->
        left = Enum.join(left.list, " ")
        right = Enum.join(right.list, " ")

        if Enum.any?(scores, fn {_algo, score} -> score > opts(opts, :match_at) end) do
          %{left: left, right: right, metrics: scores, match: 1}
        else
          %{left: left, right: right, metrics: scores, match: 0}
        end

      _ ->
        nil
    end
  end

  @spec phonemes(binary() | %Corpus{}) :: list()
  @doc """
  Returns list of unqieu phonetic representations of a  string resulting from the single and
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

  @doc """
  Return the default option values
  """
  def default_opts, do: @opts

  @doc """
  List of algorithms available for us in making comparisons.
  """
  def algorithms(), do: list_algorithms()

  def algorithms(opts), do: list_algorithms(opts)

  @doc """
  Round data types that can be rounded to 2 decimal points.
  """
  def r(v) when is_float(v), do: Float.round(v, 2)
  def r(v) when is_binary(v), do: Float.round(String.to_float(v), 2)
  def r(v) when is_integer(v), do: Float.round(v / 1, 2)
end
