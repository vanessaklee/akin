defmodule Akin.Hamming do
  @moduledoc """
  This module contains functions to calculate the Hamming distance between 2 given strings
  """
  @behaviour Akin.Task
  alias Akin.Corpus

  @spec compare(%Corpus{}, %Corpus{}) :: float()
  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  @doc """
  Calculates the Hamming distance between 2 given strings.

  ## Examples

    iex> Akin.Hamming.compare(%Akin.Corpus{string: "toned"}, %Akin.Corpus{string: "roses"})
    3
    iex> Akin.Hamming.compare(%Akin.Corpus{string: "toned"}, %Akin.Corpus{string: "hamming"})
    nil
    iex> Akin.Hamming.compare(%Akin.Corpus{string: "toned"}, %Akin.Corpus{string: "toned"})
    0
  """
  def compare(%Corpus{string: left}, %Corpus{string: right}, _opts), do: compare(left, right)

  def compare(%Corpus{string: left}, %Corpus{string: right}) do
    compare(left, right)
  end

  def compare(left, right)
      when byte_size(left) == 0 or
             byte_size(right) == 0 or
             byte_size(left) != byte_size(right) do
    nil
  end

  def compare(left, right) when left == right, do: 0

  def compare(left, right) when is_binary(left) and is_binary(right) do
    left
    |> String.codepoints()
    |> Enum.zip(right |> String.codepoints())
    |> Enum.count(fn {cp1, cp2} -> cp1 != cp2 end)
  end
end
