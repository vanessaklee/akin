defmodule Akin.Tversky do
  @moduledoc """
  This module contains functions to calculate the [Tversky index
  ](https://en.wikipedia.org/wiki/Tversky_index) between two given
  strings
  """
  import Akin.Util, only: [ngram_tokenize: 2, intersect: 2]

  use Akin.StringMetric
  @default_alpha 1
  @default_beta 1

  @doc """
  Calculates the Tversky index between two given strings with
  a default alpha of 1 and beta of 1

  This is equivalent of Tanimoto coefficient

  #### Options
  - **ngram_size**: positive integer greater than 0, to tokenize the strings

  #### Options under development
  - **alpha**: weight of the prototype sequence
  - **beta**: weight of the variant sequence

  Note: If any of them is not specified as part of the options object
  they are set to the default value of 1

  ## Examples
      iex> Akin.Tversky.compare("contact", "context", [ngram_size: 4])
      0.14285714285714285
      iex> Akin.Tversky.compare("contact", "context")
      0.3333333333333333
      iex> Akin.Tversky.compare("contact", "context", [ngram_size: 1])
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

    nmatches = intersect(left_ngrams, right_ngrams) |> length

    left_diff_length = (left_ngrams -- right_ngrams) |> length
    right_diff_length = (right_ngrams -- left_ngrams) |> length

    nmatches / (@default_alpha * left_diff_length + @default_beta * right_diff_length + nmatches)
  end
end
