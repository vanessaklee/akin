defmodule Akin.DiceSorensen do
  @moduledoc """
  This module contains functions to calculate the Sorensen-Dice coefficient of
  two strings.
  """
  @behaviour Akin.Task
  import Akin.Util, only: [ngram_tokenize: 2, intersect: 2]
  alias Akin.Corpus

  @spec compare(%Corpus{}, %Corpus{}) :: float()
  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  @doc """
  Calculates the Sorensen-Dice coefficient of two given strings with a
  specified ngram size passed as the third argument.

  ## Examples

    iex> Akin.DiceSorensen.compare(%Akin.Corpus{string: "night"}, %Akin.Corpus{string: "nacht"}, [ngram_size: 1])
    0.6
    iex> Akin.DiceSorensen.compare(%Akin.Corpus{string: "night"}, %Akin.Corpus{string: "nacht"}, [])
    0.25
    iex> Akin.DiceSorensen.compare(%Akin.Corpus{string: "night"}, %Akin.Corpus{string: "nacht"}, [ngram_size: 3])
    0.0
  """
  def compare(%Corpus{string: left}, %Corpus{string: right}) do
    compare(left, right, Akin.default_ngram_size())
  end

  def compare(%Corpus{string: left}, %Corpus{string: right}, opts) when is_list(opts) do
    compare(left, right, Keyword.get(opts, :ngram_size) || Akin.default_ngram_size())
  end

  def compare(left, right, ngram_size)
      when ngram_size == 0 or byte_size(left) < ngram_size or byte_size(right) < ngram_size,
      do: 0.0

  def compare(left, right, _ngram_size) when left == right,
    do: 1.0

  def compare(left, right, ngram_size)
      when is_integer(ngram_size) do
    left_ngrams = left |> ngram_tokenize(ngram_size)
    right_ngrams = right |> ngram_tokenize(ngram_size)
    nmatches = intersect(left_ngrams, right_ngrams) |> length
    2 * nmatches / (length(left_ngrams) + length(right_ngrams))
  end

  def compare(_, _, _), do: 0.0
end
