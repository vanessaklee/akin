defmodule Akin.Hamming do
  @moduledoc """
  This module contains functions to calculate the Hamming Distance between 2 given strings. The
  Hamming Distance is the the smallest number of substitutions needed to change one string into the
  other string.
  """
  @behaviour Akin.Task
  alias Akin.Corpus

  @spec compare(%Corpus{}, %Corpus{}) :: float()
  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  @doc """
  Calculates the Hamming distance between 2 given strings.

  ## Examples

    iex> Akin.Hamming.compare(%Akin.Corpus{string: "toned"}, %Akin.Corpus{string: "roses"}, [])
    0.4
    iex> Akin.Hamming.compare(%Akin.Corpus{string: "toned"}, %Akin.Corpus{string: "hamming"}, [])
    0.0
    iex> Akin.Hamming.compare(%Akin.Corpus{string: "toned"}, %Akin.Corpus{string: "toned"}, [])
    1.0
  """
  def compare(%Corpus{string: left}, %Corpus{string: right}, _opts) do
    case compare(left, right) do
      0 -> 0.0
      1 -> 1.0
      i -> 1 - (i/byte_size(left))
    end
  end

  def compare(left, right)
      when byte_size(left) == 0 or
             byte_size(right) == 0 or
             byte_size(left) != byte_size(right) do
    0
  end

  def compare(left, right) when left == right, do: 1

  def compare(left, right) when is_binary(left) and is_binary(right) do
    left
    |> String.codepoints()
    |> Enum.zip(right |> String.codepoints())
    |> Enum.count(fn {cp1, cp2} -> cp1 != cp2 end)
  end
end
