defmodule Akin.Similarity.DiceSorensen do
  @moduledoc """
  This module contains functions to calculate the Sorensen-Dice coefficient of
  2 given strings.
  """
  require IEx
  import Akin.Util, only: [ngram_tokenize: 2, intersect: 2]

  @behaviour Akin.StringMetric
  @default_ngram_size 2

  @doc """
  Calculates the Sorensen-Dice coefficient of two given strings with the ngram
  size set to a default value of 2.
  ## Examples
      iex> Akin.Similarity.DiceSorensen.compare("night", "nacht")
      0.25
      iex> Akin.Similarity.DiceSorensen.compare("context", "contact")
      0.5
  """
  def compare(left, right) when is_binary(left) and is_binary(right) do
    compare(left, right, @default_ngram_size)
  end

  @doc """
  Calculates the Sorensen-Dice coefficient of two given strings with a
  specified ngram size passed as the third argument.
  ## Examples
      iex> Akin.Similarity.DiceSorensen.compare("night", "nacht", 1)
      0.6
      iex> Akin.Similarity.DiceSorensen.compare("night", "nacht", 2)
      0.25
      iex> Akin.Similarity.DiceSorensen.compare("night", "nacht", 3)
      0.0
  """
  def compare(left, right, ngram_size)
      when ngram_size == 0 or byte_size(left) < ngram_size or byte_size(right) < ngram_size,
      do: nil

  def compare(left, right, _ngram_size) when left == right, do: 1

  def compare(left, right, ngram_size) do
    left_ngrams = left |> ngram_tokenize(ngram_size)
    right_ngrams = right |> ngram_tokenize(ngram_size)
    nmatches = intersect(left_ngrams, right_ngrams) |> length
    2 * nmatches / (length(left_ngrams) + length(right_ngrams))
  end
end
