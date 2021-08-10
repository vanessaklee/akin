defmodule Akin.Similarity.MetaphoneExact do
  @moduledoc """
  Calculates the [Metaphone Phonetic Algorithm](http://en.wikipedia.org/wiki/
  Metaphone) metric of two strings.
  """
  # @behaviour Akin.StringMetric
  use Akin.StringMetric

  import Akin.Phonetic.MetaphoneAlgorithm, only: [compute: 1]
  import Akin.Util, only: [len: 1, is_alphabetic?: 1]
  import String, only: [first: 1]

  @doc """
    Compares two values phonetically and returns a boolean of whether they match
    or not.
    ## Examples
      iex> Akin.Similarity.MetaphoneExact.compare("Colorado", "Kolorado")
      1
      iex> Akin.Similarity.MetaphoneExact.compare("Moose", "Elk")
      0
  """
  def compare(left, right) do
    case len(left) == 0 || !is_alphabetic?(first(left)) || len(right) == 0 || !is_alphabetic?(first(right)) do
      false ->
        if compute(left) == compute(right), do: 1, else: 0
      true ->
        nil
    end
  end
end
