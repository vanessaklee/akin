defmodule Akin.Hamming do
  @moduledoc """
  This module contains functions to calculate the Hamming Distance between 2 given strings. The
  Hamming Distance is the the smallest number of substitutions needed to change one string into the
  other string.

  If the strings are not the same length, nil is returned
  If the string are equal, 0.0 is returned.
  """
  @behaviour Akin.Task
  alias Akin.Corpus

  @spec compare(%Corpus{}, %Corpus{}) :: float()
  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  @doc """
  Calculates the Hamming distance between 2 given strings.

  ## Examples

    iex> Akin.Hamming.compare(%Akin.Corpus{string: "toned"}, %Akin.Corpus{string: "roses"}, [])
    0.6
    iex> Akin.Hamming.compare(%Akin.Corpus{string: "toned"}, %Akin.Corpus{string: "hamming"}, [])
    nil
    iex> Akin.Hamming.compare(%Akin.Corpus{string: "toned"}, %Akin.Corpus{string: "toned"}, [])
    0.0
  """
  def compare(%Corpus{string: left}, %Corpus{string: right}, _opts) do
    compare(left, right)
  end

  def compare(_, _, _), do: nil

  def compare(left, right)
      when byte_size(left) == 0 or
             byte_size(right) == 0 or
             byte_size(left) != byte_size(right) do
    nil
  end

  def compare(left, right) when left == right, do: 0.0

  def compare(left, right) when is_binary(left) and is_binary(right) do
    score = left
      |> String.codepoints()
      |> Enum.zip(right |> String.codepoints())
      |> Enum.count(fn {cp1, cp2} -> cp1 != cp2 end)
    score/byte_size(left)
  end
end
