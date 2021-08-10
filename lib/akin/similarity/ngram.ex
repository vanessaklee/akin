defmodule Akin.Similarity.Ngram do
  @moduledoc """
  This module contains functions to calculate the ngram distance between two
  given strings based on this
  [paper](webdocs.cs.ualberta.ca/~kondrak/papers/spire05.pdf)
  """
  require IEx
  import Akin.Util, only: [ngram_tokenize: 2, intersect: 2]

  # @behaviour Akin.StringMetric
  use Akin.StringMetric

  @doc """
  Calculates the ngram similarity between two given strings with a specified
  ngram size

  ## Examples
      iex> Akin.Similarity.Ngram.compare("night", "naght", 3)
      0.3333333333333333
      iex> Akin.Similarity.Ngram.compare("context", "contact", 1)
      0.7142857142857143
  """
  def compare(left, right) do
    compare(left, right, Akin.default_ngram_size())
  end
  def compare(left, right, opts) when is_list(opts) do
    compare(left, right, Keyword.get(opts, :ngram_size) || Akin.default_ngram_size())
  end
  def compare(left, right, ngram_size)
      when ngram_size == 0 or byte_size(left) < ngram_size or byte_size(right) < ngram_size do
        nil
  end
  def compare(left, right, _ngram_size) when left == right, do: 1
  def compare(left, right, ngram_size) when is_integer(ngram_size) do
    left_ngrams = left |> ngram_tokenize(ngram_size)
    right_ngrams = right |> ngram_tokenize(ngram_size)
    nmatches = intersect(left_ngrams, right_ngrams) |> length
    nmatches / max(length(left_ngrams), length(right_ngrams))
  end
end
