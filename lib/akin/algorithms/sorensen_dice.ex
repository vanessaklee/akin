defmodule Akin.SorensenDice do
  @moduledoc """
  This module contains functions to calculate the Sorensen-Dice coefficient of two strings.
  """
  @behaviour Akin.Task
  import Akin.Util, only: [ngram_tokenize: 2, opts: 2, intersect: 2]
  alias Akin.Corpus

  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  @doc """
  Calculates the Sorensen-Dice coefficient of two given strings with a
  specified ngram size passed as the third argument.

  ## Examples

    iex> Akin.SorensenDice.compare(%Akin.Corpus{string: "night"}, %Akin.Corpus{string: "nacht"}, [ngram_size: 1])
    0.6
    iex> Akin.SorensenDice.compare(%Akin.Corpus{string: "night"}, %Akin.Corpus{string: "nacht"}, [])
    0.25
    iex> Akin.SorensenDice.compare(%Akin.Corpus{string: "night"}, %Akin.Corpus{string: "nacht"}, [ngram_size: 3])
    0.0
  """
  def compare(%Corpus{string: left}, %Corpus{string: right}, opts \\ []) do
    perform(left, right, opts(opts, :ngram_size))
  end

  defp perform(left, right, ngram_size)
      when ngram_size == 0 or byte_size(left) < ngram_size or byte_size(right) < ngram_size,
      do: 0.0

  defp perform(left, right, _ngram_size) when left == right,
    do: 1.0

  defp perform(left, right, ngram_size)
      when is_integer(ngram_size) do
    left_ngrams = left |> ngram_tokenize(ngram_size)
    right_ngrams = right |> ngram_tokenize(ngram_size)
    nmatches = intersect(left_ngrams, right_ngrams) |> length

    2 * nmatches / (length(left_ngrams) + length(right_ngrams))
  end

  defp perform(_, _, _), do: 0.0
end
