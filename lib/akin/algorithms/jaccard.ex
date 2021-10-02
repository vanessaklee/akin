defmodule Akin.Jaccard do
  @moduledoc """
  This module contains functions to calculate the Jaccard similarity between two strings
  """
  @behaviour Akin.Task
  import Akin.Util, only: [ngram_tokenize: 2, ngram_size: 1, intersect: 2]
  alias Akin.Corpus

  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  @doc """
  Calculates the Jaccard similarity coefficient between two given strings with
  the specified ngram size

  ## Examples
    iex> Akin.Jaccard.compare(%Akin.Corpus{string: "contact"}, %Akin.Corpus{string: "context"}, [ngram_size: 3])
    0.25
    iex> Akin.Jaccard.compare(%Akin.Corpus{string: "contact"}, %Akin.Corpus{string: "context"}, [ngram_size: 1])
    0.5555555555555556
  """
  def compare(left, right, opts \\ []) when is_list(opts) do
    perform(left, right, ngram_size(opts))
  end

  defp perform(%Corpus{string: left}, %Corpus{string: right}, n)
      when n <= 0 or byte_size(left) < n or byte_size(right) < n do
    nil
  end

  defp perform(%Corpus{string: left}, %Corpus{string: right}, _n) when left == right, do: 1

  defp perform(%Corpus{string: left}, %Corpus{string: right}, ngram_size)
      when is_integer(ngram_size) do
    left_ngrams = left |> ngram_tokenize(ngram_size)
    right_ngrams = right |> ngram_tokenize(ngram_size)
    nmatches = left_ngrams |> intersect(right_ngrams) |> length
    nmatches / (length(left_ngrams) + length(right_ngrams) - nmatches)
  end
end
