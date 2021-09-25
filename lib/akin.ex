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
  import Akin.Util, only: [modulize: 1, prime: 1]
  alias Akin.Primed
  @default_ngram_size 2
  @opts [ngram_size: 2, threshold: "normal"]

  @doc """
  Compare two strings using all supported algorithm. Return a map of metrics.
  """
  @algorithms ["bag_distance", "chunk_set", "dice_sorensen", "hamming", "jaccard", "jaro_winkler", "levenshtein",
  "metaphone", "double_metaphone", "double_metaphone._chunks", "ngram", "overlap", "sorted_chunks", "tversky"]

  @substring_algorithms ["chunk_set", "overlap", "sorted_chunks", "double_metaphone._chunks"]

  def compare(left, right, algorithms \\ @algorithms, opts \\ @opts)

  def compare(left, right, algorithms, opts) when is_binary(left) and is_binary(right) do
    compare(prime(left), prime(right), algorithms, opts)
  end

  def compare(%Primed{} = left, %Primed{} = right, algorithms, opts) do
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
    |> Enum.into(%{})
  end

  @doc """
  Compare two strings using all algorithm that handle substrings and/or chunks:
  "chunk_set", "overlap", and "sorted_chunks". Return a map of metrics.
  """
  def substring_compare(left, right, opts \\ @opts)

  def substring_compare(left, right, opts) when is_binary(left) and is_binary(right) do
    if String.contains?(left, " ") or String.contains?(right, " ") do
      compare(prime(left), prime(right), @substring_algorithms, opts)
    else
      compare(prime(left), prime(right), @algorithms, opts)
    end
  end

  @doc """
  Compare two strings using a particular algorithm. Return a map of metrics. The algorithm
  name must be an atom (i.e. :jaro_winkler)
  """
  def compare_using(algorithm, left, right, opts \\ @opts)

  def compare_using(algorithm, left, right, opts) when is_binary(left) and is_binary(right) do
    compare_using(algorithm, prime(left), prime(right), opts)
  end

  def compare_using(algorithm, %Primed{} = left, %Primed{} = right, opts) do
    apply(modulize(algorithm), :compare, [left, right, opts])
  end

  def max(left, right) do
    scores = compare(left, right)
    {_k, max_val} = Enum.max_by(scores, fn {_k, v} -> v end)
    Enum.filter(scores, fn {_k, v} -> v == max_val end)
  end

  def default_ngram_size, do: @default_ngram_size
end
