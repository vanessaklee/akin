defmodule Akin do
  @moduledoc """
  Compare two strings for similarity. Bias is set to 0.95.
  """
  import Akin.Util, only: [modulize: 1]
  @default_ngram_size 2

  @doc """
  Compare two strings using all supported algorithm. Return a map of metrics.

  `opts`is a keyword list of options. The only support option at this time is
  ngram size. The default is 2. To change it set an ngram size in `opt`.

  opts = [ngram_size: 3]
  """
  def compare(left, right, opts \\ [])
  def compare(left, right, opts) do
    algorithms = [:bag_distance, :chunk_set, :dice_sorensen, :hamming, :jaccard, :jaro_winkler, :levenshtein,
      :metaphone_exact, :metaphone_scores, :n_gram, :overlap, :sorted_chunks, :string_compare, :tversky]
    Enum.reduce(algorithms, %{}, fn algorithm, acc ->
      Map.put(acc, algorithm, apply(modulize(algorithm), :compare, [left, right, opts]))
    end)
    |> Enum.filter(fn {_, v} -> v != nil end)
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
  def compare_using(algorithm, left, right, opts) do
    apply(modulize(algorithm), :compare, [left, right, opts])
  end

  def default_ngram_size, do: @default_ngram_size
end
