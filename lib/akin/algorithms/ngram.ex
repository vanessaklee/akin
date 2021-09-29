defmodule Akin.Ngram do
  @moduledoc """
  This module contains functions to calculate the ngram distance between two
  given strings based on this
  [paper](webdocs.cs.ualberta.ca/~kondrak/papers/spire05.pdf)
  """
  @behaviour Akin.Task
  import Akin.Util, only: [ngram_tokenize: 2, intersect: 2]
  alias Akin.Corpus

  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  @doc """
  Calculates the ngram similarity between two given strings with a specified
  ngram size

  ## Examples

    iex> Akin.Ngram.compare(%Akin.Corpus{string: "night"}, %Akin.Corpus{string: "naght"}, 3)
    0.3333333333333333
    iex> Akin.Ngram.compare(%Akin.Corpus{string: "context"}, %Akin.Corpus{string: "contact"}, 1)
    0.7142857142857143
  """
  def compare(%Corpus{} = left, %Corpus{} = right) do
    compare(left, right, Keyword.get(Akin.default_opts(), :ngram_size))
  end

  def compare(left, right, opts \\ Akin.default_opts())

  def compare(%Corpus{} = left, %Corpus{} = right, opts) when is_list(opts) do
    ngram_size = Keyword.get(opts, :ngram_size) || Keyword.get(Akin.default_opts(), :ngram_size)
    compare(left, right, ngram_size)
  end

  def compare(%Corpus{string: left}, %Corpus{string: right}, ngram_size)
      when ngram_size == 0 or byte_size(left) < ngram_size or byte_size(right) < ngram_size do
    nil
  end

  def compare(%Corpus{string: left}, %Corpus{string: right}, _ngram_size) when left == right,
    do: 1

  def compare(%Corpus{string: left}, %Corpus{string: right}, ngram_size)
      when is_integer(ngram_size) do
    left_ngrams = left |> ngram_tokenize(ngram_size)
    right_ngrams = right |> ngram_tokenize(ngram_size)
    nmatches = intersect(left_ngrams, right_ngrams) |> length
    nmatches / max(length(left_ngrams), length(right_ngrams))
  end
end
