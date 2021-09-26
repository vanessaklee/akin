defmodule Akin.Metaphone do
  @moduledoc """
  Calculates the [Metaphone Phonetic Algorithm](http://en.wikipedia.org/wiki/
  Metaphone) metric of two strings.
  """
  @behaviour Akin.Task
  import Akin.Metaphone.Metaphone, only: [compute: 1]
  import Akin.Util, only: [len: 1, is_alphabetic?: 1]
  import String, only: [first: 1]
  alias Akin.Corpus

  @spec compare(%Corpus{}, %Corpus{}) :: float()
  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  @doc """
  Compares two values phonetically. Return 1 if phonetic representations match, 0 if not.

  ## Examples

    iex> Akin.Metaphone.compare(Akin.Util.compose("Colorado"), Akin.Util.compose("Kolorado"))
    1.0
    iex> Akin.Metaphone.compare(Akin.Util.compose("Moose"), Akin.Util.compose("Elk"))
    0.0
  """
  def compare(%Corpus{} = left, %Corpus{} = right, _opts), do: compare(left, right)

  def compare(%Corpus{string: left}, %Corpus{string: right}) do
    case len(left) == 0 || !is_alphabetic?(first(left)) || len(right) == 0 ||
           !is_alphabetic?(first(right)) do
      false ->
        if compute(left) == compute(right), do: 1.0, else: 0.0

      true ->
        nil
    end
  end
end
