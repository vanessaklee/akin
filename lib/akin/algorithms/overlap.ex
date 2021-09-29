defmodule Akin.Overlap do
  @moduledoc """
  Implements the Overlap Similarity Metric.
  """
  @behaviour Akin.Task
  import Akin.Util, only: [ngram_tokenize: 2, intersect: 2]
  alias Akin.Corpus

  @spec compare(%Corpus{}, %Corpus{}) :: float()
  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  @doc """
  Compares two values using the Overlap Similarity metric and returns the
  coefficient. It takes the ngram size as the third argument.

  ## Examples

    iex> Akin.Overlap.compare(%Akin.Corpus{string: "compare me"}, %Akin.Corpus{string: "to me"}, [])
    0.5
    iex> Akin.Overlap.compare(%Akin.Corpus{string: "compare me"}, %Akin.Corpus{string: "to me"}, [ngram_size: 1])
    0.8
    iex> Akin.Overlap.compare(%Akin.Corpus{string: "or me"}, %Akin.Corpus{string: "me"}, 1)
    1.0
  """
  def compare(left, right, opts \\ Akin.default_opts())

  def compare(%Corpus{} = left, %Corpus{} = right, opts) when is_list(opts) do
    ngram_size = Keyword.get(opts, :ngram_size) || Keyword.get(Akin.default_opts(), :ngram_size)
    compare(left, right, ngram_size)
  end

  def compare(%Corpus{string: left}, %Corpus{string: right}, n) when is_integer(n) do
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
