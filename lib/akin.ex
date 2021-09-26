defmodule Akin do
  @moduledoc """
  Compare two strings for similarity. Bias is set to 0.95.

  `opts` is a keyword list of options (i.e. [ngram_size: 3]). There are two
  available options.

  1. `ngram_size` - default is 2
  2. `threshold` - default is "normal", threshold for matching (only used in double metaphone algorithm)
    * "strict": both encodings for each string must match
    * "strong": the primary encoding for each string must match
    * "normal": the primary encoding of one string must match either encoding of other string (default)
    * "weak":   either primary or secondary encoding of one string must match one encoding of other string
  """
  import Akin.Util, only: [modulize: 1, compose: 1]
  alias Akin.Corpus

  NimbleCSV.define(CSVParse, separator: "\t")

  @default_ngram_size 2
  @opts [ngram_size: 2, threshold: "normal"]

  @doc """
  Compare two strings using all supported algorithm. Return a map of metrics.
  """
  @algorithms [
    "bag_distance",
    "chunk_set",
    "dice_sorensen",
    "hamming",
    "jaccard",
    "jaro_winkler",
    "levenshtein",
    "metaphone",
    "double_metaphone",
    "double_metaphone._chunks",
    "ngram",
    "overlap",
    "sorted_chunks",
    "tversky"
  ]

  @substring_algorithms ["chunk_set", "overlap", "sorted_chunks", "double_metaphone._chunks"]

  @spec compare(binary(), binary()) :: float()
  @spec compare(binary(), binary(), list(), keyword() | nil) :: float()
  @spec compare(%Corpus{}, %Corpus{}, list(), keyword()) :: float()
  def compare(left, right, algorithms \\ @algorithms, opts \\ @opts)

  def compare(left, right, algorithms, opts) when is_binary(left) and is_binary(right) do
    compare(compose(left), compose(right), algorithms, opts)
  end

  def compare(%Corpus{} = left, %Corpus{} = right, algorithms, opts) do
    Enum.reduce(algorithms, %{}, fn algorithm, acc ->
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

  # TODO write tests for match using AMiner like the old And tests

  @spec match(%Corpus{} | binary(), %Corpus{} | binary(), keyword()) :: float()
  @doc """
  Accept one Corpus struct, a list of Corpus structs, and a opts list to then compare the first binary with
  each of the structs in the second parameter. Return a list of binaries from the list which are a likely
  match for the first binary. A likely match has a max score higher than 0.9
  """
  def match(left, rights, opts \\ [])

  def match(left, rights, opts) when is_binary(left) and is_list(rights) do
    rights = Enum.map(rights, fn right -> compose(right) end)
    match(compose(left), rights, opts)
  end

  def match(%Corpus{} = left, rights, opts) do
    Enum.reduce(rights, [], fn %Corpus{} = right, acc ->
      if Enum.any?(max(left, right, opts), fn {_algo, score} -> score > 0.9 end) do
        [Enum.join(right.chunks, " ") | acc]
      else
        acc
      end
    end)
  end

  @spec compare_using(atom(), %Corpus{}, %Corpus{}, keyword()) :: float()
  @doc """
  Compare two strings using a particular algorithm. Return a map of metrics. The algorithm
  name must be an atom (i.e. :jaro_winkler)
  """
  def compare_using(algorithm, left, right, opts \\ @opts)

  def compare_using(algorithm, left, right, opts) when is_binary(left) and is_binary(right) do
    compare_using(algorithm, compose(left), compose(right), opts)
  end

  def compare_using(algorithm, %Corpus{} = left, %Corpus{} = right, opts) do
    apply(modulize(algorithm), :compare, [left, right, opts]) |> Float.round(2)
  end

  @spec match(%Corpus{}, %Corpus{}, keyword()) :: float()
  @doc """
  Compare two strings using all algorithm that handle substrings and/or chunks:
  "chunk_set", "overlap", and "sorted_chunks". Return a map of metrics.
  """
  def substring_compare(left, right, opts \\ @opts)

  def substring_compare(left, right, opts) when is_binary(left) and is_binary(right) do
    if String.contains?(left, " ") or String.contains?(right, " ") do
      compare(compose(left), compose(right), @substring_algorithms, opts)
    else
      compare(compose(left), compose(right), @algorithms, opts)
    end
  end

  @spec max(%Corpus{}, %Corpus{}, keyword()) :: list(tuple())
  @spec max(map()) :: float()
  def max(%{} = scores) do
    {_k, max_val} = Enum.max_by(scores, fn {_k, v} -> v end)
    Enum.filter(scores, fn {_k, v} -> v == max_val end)
  end

  def max(left, right, opts \\ []) do
    compare(left, right, @algorithms, opts)
    |> max()
  end

  def default_ngram_size, do: @default_ngram_size

  defp r(v) when is_float(v), do: Float.round(v, 2)
  defp r(v) when is_binary(v), do: Float.round(String.to_float(v), 2)
  defp r(v) when is_integer(v), do: Float.round(v / 1, 2)
end
