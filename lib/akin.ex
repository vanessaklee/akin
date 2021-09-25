defmodule Akin do
  @moduledoc """
  Compare two strings for similarity. Bias is set to 0.95.
  """
  import Akin.Util, only: [modulize: 1, prime: 1]
  alias Akin.Primed
  @default_ngram_size 2

  @doc """
  Compare two strings using all supported algorithm. Return a map of metrics.

  `opts`is a keyword list of options. The only support option at this time is
  ngram size. The default is 2. To change it set an ngram size in `opt`.

  opts = [ngram_size: 3]
  """
  @algorithms ["bag_distance", "chunk_set", "dice_sorensen", "hamming", "jaccard", "jaro_winkler", "levenshtein",
  "metaphone", "double_metaphone._weak", "double_metaphone._normal", "double_metaphone._strict", "ngram",
  "overlap", "sorted_chunks", "string_compare", "tversky"]

  # ["bag_distance", "chunk_set", "dice_sorensen", "hamming", "jaccard", "jaro_winkler", "levenshtein",
  # "metaphone", "double_metaphone._weak", "double_metaphone._normal", "double_metaphone._strict", "ngram",
  # "overlap", "sorted_chunks", "tversky"]

  def compare(left, right, opts \\ [])

  def compare(left, right, opts) when is_binary(left) and is_binary(right) do
    compare(prime(left), prime(right), opts)
  end

  def compare(%Primed{} = left, %Primed{} = right, opts) do
    IO.inspect(left, label: "left")
    IO.inspect(right, label: "right")
    Enum.reduce(@algorithms , %{}, fn algorithm, acc ->
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
  Compare two strings using a particular algorithm. Return a map of metrics. The algorithm
  name must be an atom (i.e. :jaro_winkler)

  `opts`is a keyword list of options. The only support option at this time is
  ngram size. The default is 2. To change it set an ngram size in `opt`.

  opts = [ngram_size: 3]
  """
  def compare_using(algorithm, left, right, opts \\ [])

  def compare_using(algorithm, left, right, opts) when is_binary(left) and is_binary(right) do
    compare_using(algorithm, prime(left), prime(right), opts)
  end

  def compare_using(algorithm, %Primed{} = left, %Primed{} = right, opts) do
    apply(modulize(algorithm), :compare, [left, right, opts])
  end

  def max(left, right) do
    compare(left, right)
    |> Enum.max_by(fn {_k, v} -> v end)
  end

  def default_ngram_size, do: @default_ngram_size
end
