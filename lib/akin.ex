defmodule Akin do
  @moduledoc """
  To compare two strings for similarity. Bias is set to 0.95.
  """
  @bias 0.95

  @doc """
  Compares two strings using all algorithm. Return a map of metrics.

  `opts` can be n gram size in case of Dice Sorensen, Jaccard, N Gram similarity and can be weights in case of Weighted Levenshtein
  """
  def compare(left, right, opts \\ %{})
  def compare(left, right, opts) do
    algorithms = [:bag_distance, :chunk_set, :dice_sorensen, :hamming, :jaccard, :jaro_winkler, :levenshtein,
      :metaphone, :n_gram, :overlap, :sorted_chunks, :string_compare]
    Enum.reduce(algorithms, %{}, fn algorithm, acc ->
      score = compare_using(algorithm, left, right, opts)
      Map.put(acc, algorithm, score)
    end)
  end
  def compare_using(metric_type, left, right, opts \\ %{})
  def compare_using(metric_type, left, right, opts)
  def compare_using(:bag_distance, left, right, _opts) do
    String.bag_distance(left, right)
  end
  def compare_using(:chunk_set, left, right, opts) do
    bias = Map.get(opts, :bias) || @bias
    Akin.Similarity.ChunkSet.standard_similarity(left, right) * bias
  end
  def compare_using(:dice_sorensen, left, right, opts) do
    Akin.Similarity.DiceSorensen.compare(left, right, opts)
  end
  def compare_using(:hamming, left, right, _opts) do
    Akin.Similarity.Hamming.compare(left, right)
  end
  def compare_using(:jaccard, left, right, opts) do
    Akin.Similarity.Jaccard.compare(left, right, opts)
  end
  def compare_using(:jaro_winkler, left, right, _opts) do
    Akin.Similarity.JaroWinkler.compare(left, right)
  end
  def compare_using(:levenshtein, left, right, _opts) do
    Akin.Similarity.Levenshtein.compare(left, right)
  end
  def compare_using(:metaphone, left, right, _opts) do
    Akin.Phonetic.MetaphoneMetric.compare(left, right)
  end
  def compare_using(:n_gram, left, right, opts) do
    Akin.Similarity.NGram.compare(left, right, opts)
  end
  def compare_using(:overlap, left, right, _opts) do
    Akin.Similarity.Overlap.compare(left, right)
  end
  def compare_using(:tversky, left, right, _opts) do
    Akin.Similarity.Tversky.compare(left, right)
  end
  def compare_using(:sorted_chunks, left, right, opts) do
    bias = Map.get(opts, :bias) || @bias
    Akin.Similarity.SortedChunks.standard_similarity(left, right) * bias
  end
  def compare_using(:string_compare, left, right, _opts) do
    Akin.Similarity.StringCompare.compare(left, right)
  end
end
