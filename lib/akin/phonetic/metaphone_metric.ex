defmodule Akin.Phonetic.MetaphoneMetric do
  @moduledoc """
  Calculates the [Metaphone Phonetic Algorithm](http://en.wikipedia.org/wiki/
  Metaphone) metric of two strings.
  """

  import Akin.Phonetic.MetaphoneAlgorithm, only: [compute: 1]
  import Akin.Util, only: [len: 1, is_alphabetic?: 1]
  import String, only: [first: 1]

  @doc """
    Compares two values phonetically and returns a boolean of whether they match
    or not.
    ## Examples
      iex> Akin.Phonetic.MetaphoneMetric.compare("Colorado", "Kolorado")
      true
      iex> Akin.Phonetic.MetaphoneMetric.compare("Moose", "Elk")
      false
  """
  def compare(left, right) do
    case len(left) == 0 || !is_alphabetic?(first(left)) || len(right) == 0 || !is_alphabetic?(first(right)) do
      false ->
        compute(left) == compute(right)

      true ->
        nil
    end
  end
end
