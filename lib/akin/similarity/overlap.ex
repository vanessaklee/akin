defmodule Akin.Similarity.Overlap do
  @moduledoc """
  Implements the [Overlap Similarity Metric](http://en.wikipedia.org/wiki/
  Overlap_coefficient)
  """
  import Akin.Util, only: [ngram_tokenize: 2, intersect: 2]

  @behaviour Akin.StringMetric

  @doc """
  Compares two values using the Overlap Similarity metric and returns the
  coefficient.  It takes the ngram size as the third argument, and, if
  none is provided, assumes that you want to use 1.
  ## Examples
      iex> Akin.Similarity.Overlap.compare("compare me", "to me")
      0.8
      iex> Akin.Similarity.Overlap.compare("compare me", "to me", 2)
      0.5
      iex> Akin.Similarity.Overlap.compare("or me", "me", 1)
      1.0
  """
  def compare(left, right), do: compare(left, right, 1)

  def compare(left, right, n) do
    cond do
      n <= 0 || String.length(left) < n || String.length(right) < n ->
        nil

      left == right ->
        1.0

      true ->
        tokens_left = ngram_tokenize(left, n)
        tokens_right = ngram_tokenize(right, n)
        ms = tokens_left |> intersect(tokens_right) |> length
        ms / min(length(tokens_left), length(tokens_right))
    end
  end
end
