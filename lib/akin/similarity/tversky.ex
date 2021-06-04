defmodule Akin.Similarity.Tversky do
  @moduledoc """
  This module contains functions to calculate the [Tversky index
  ](https://en.wikipedia.org/wiki/Tversky_index) between two given
  strings
  """
  import Akin.Util, only: [ngram_tokenize: 2, intersect: 2]

  @behaviour Akin.StringMetric
  @default_ngram_size 1
  @default_alpha 1
  @default_beta 1

  @doc """
  Calculates the Tversky index between two given strings with
  a default ngram size of 1, alpha of 1 and beta of 1

  This is equivalent of Tanimoto coefficient

  ## Examples
      iex> Akin.Similarity.Tversky.compare("contact", "context")
      0.5555555555555556
      iex> Akin.Similarity.Tversky.compare("ht", "hththt")
      0.3333333333333333
  """
  def compare(left, right) do
    compare(left, right, %{n_gram_size: @default_ngram_size, alpha: @default_alpha, beta: @default_beta})
  end

  @doc """
  Calculates the Tversky index between two given strings with
  the specified options passed as a map of key, value pairs.

  #### Options
  - **n_gram_size**: positive integer greater than 0, to tokenize the strings
  - **alpha**: weight of the prototype sequence
  - **beta**: weight of the variant sequence

  Note: If any of them is not specified as part of the options object
  they are set to the default value of 1

  ## Examples
      iex> Akin.Similarity.Tversky.compare("contact", "context", %{n_gram_size: 4, alpha: 2, beta: 0.8})
      0.10638297872340426
      iex> Akin.Similarity.Tversky.compare("contact", "context", %{n_gram_size: 2, alpha: 0.5, beta: 0.5})
      0.5
  """
  def compare(left, right, %{n_gram_size: n}) when n <= 0 or byte_size(left) < n or byte_size(right) < n,
    do: nil

  def compare(left, right, _n) when left == right, do: 1

  def compare(left, right, %{n_gram_size: n, alpha: alpha, beta: beta}) do
    n = n || @default_ngram_size
    alpha = alpha || @default_alpha
    beta = beta || @default_beta

    left_ngrams = left |> ngram_tokenize(n)
    right_ngrams = right |> ngram_tokenize(n)

    nmatches = intersect(left_ngrams, right_ngrams) |> length

    left_diff_length = (left_ngrams -- right_ngrams) |> length
    right_diff_length = (right_ngrams -- left_ngrams) |> length

    nmatches / (alpha * left_diff_length + beta * right_diff_length + nmatches)
  end
end
