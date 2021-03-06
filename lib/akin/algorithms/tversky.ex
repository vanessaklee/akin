defmodule Akin.Tversky do
  @moduledoc """
  Functions to calculate the Tversky index
  between two strings.
  """
  @behaviour Akin.Task
  import Akin.Util, only: [ngram_tokenize: 2, opts: 2, intersect: 2]
  alias Akin.Corpus

  @default_alpha 1
  @default_beta 1

  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  @doc """
  Calculates the Tversky index between two strings. Default alpha is 1
  and beta is 1. ngram_size is a positive integer greater than 0 used
  to tokenize the strings

  ## Examples
    iex> Akin.Tversky.compare(%Akin.Corpus{string: "contact"}, %Akin.Corpus{string: "context"}, [ngram_size: 4])
    0.14285714285714285
    iex> Akin.Tversky.compare(%Akin.Corpus{string: "contact"}, %Akin.Corpus{string: "context"})
    0.3333333333333333
    iex> Akin.Tversky.compare(%Akin.Corpus{string: "contact"}, %Akin.Corpus{string: "context"}, [ngram_size: 1])
    0.5555555555555556
  """
  def compare(%Corpus{} = left, %Corpus{} = right, opts \\ []) do
    perform(left, right, opts(opts, :ngram_size))
  end

  @spec compare(%Corpus{}, %Corpus{}, integer()) :: float()
  defp perform(%Corpus{string: left}, %Corpus{string: right}, n)
       when n <= 0 or byte_size(left) < n or byte_size(right) < n do
    0.0
  end

  defp perform(%Corpus{string: left}, %Corpus{string: right}, _n) when left == right, do: 1.0

  defp perform(%Corpus{string: left}, %Corpus{string: right}, ngram_size)
       when is_integer(ngram_size) do
    left_ngrams = left |> ngram_tokenize(ngram_size)
    right_ngrams = right |> ngram_tokenize(ngram_size)

    nmatches = intersect(left_ngrams, right_ngrams) |> length

    left_diff_length = (left_ngrams -- right_ngrams) |> length
    right_diff_length = (right_ngrams -- left_ngrams) |> length

    nmatches / (@default_alpha * left_diff_length + @default_beta * right_diff_length + nmatches)
  end
end
