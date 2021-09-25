defmodule Akin.Metaphone do
  @moduledoc """
  Calculates the [Metaphone Phonetic Algorithm](http://en.wikipedia.org/wiki/
  Metaphone) metric of two strings.
  """
  use Akin.StringMetric
  import Akin.Metaphone.Metaphone, only: [compute: 1]
  import Akin.Util, only: [len: 1, is_alphabetic?: 1]
  import String, only: [first: 1]
  alias Akin.Primed

  @doc """
    Compares two values phonetically and returns a boolean of whether they match
    or not.
    ## Examples
      iex> Akin.Metaphone.compare(%Akin.Primed{string: "Colorado"}, %Akin.Primed{string: "Kolorado"})
      1
      iex> Akin.Metaphone.compare(%Akin.Primed{string: "Moose"}, %Akin.Primed{string: "Elk"})
      0
  """
  def compare(left, right, _opts), do: compare(left, right)

  def compare(%Primed{string: left} = l, %Primed{string: right} = r) do
    case len(left) == 0 || !is_alphabetic?(first(left)) || len(right) == 0 || !is_alphabetic?(first(right)) do
      false ->
        if compute(l) == compute(r), do: 1, else: 0
      true ->
        nil
    end
  end
end
