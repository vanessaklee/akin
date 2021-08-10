defmodule Akin.Similarity.Jaccard do
  @moduledoc """
  This module contains functions to calculate the Jaccard similarity between two strings
  """
  import Akin.Util, only: [ngram_tokenize: 2, intersect: 2]

  # @behaviour Akin.StringMetric
  use Akin.StringMetric

  @doc """
  Calculates the Jaccard similarity coefficient between two given strings with
  the specified ngram size

  ## Examples
      iex> Akin.Similarity.Jaccard.compare("contact", "context", 3)
      0.25
      iex> Akin.Similarity.Jaccard.compare("contact", "context", 1)
      0.5555555555555556
  """
  def compare(left, right) do
    compare(left, right, Akin.default_ngram_size())
  end
  def compare(left, right, opts) when is_list(opts) do
    compare(left, right, Keyword.get(opts, :ngram_size) || Akin.default_ngram_size())
  end
  def compare(left, right, n) when n <= 0 or byte_size(left) < n or byte_size(right) < n do
    nil
  end
  def compare(left, right, _n) when left == right, do: 1
  def compare(left, right, ngram_size) when is_integer(ngram_size) do
    left_ngrams = left |> ngram_tokenize(ngram_size)
    right_ngrams = right |> ngram_tokenize(ngram_size)
    nmatches = left_ngrams |> intersect(right_ngrams) |> length
    nmatches / (length(left_ngrams) + length(right_ngrams) - nmatches)
  end
end
