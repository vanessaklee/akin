defmodule Akin.Hamming do
  @moduledoc """
  This module contains functions to calculate the Hamming distance between 2 given strings
  """
  use Akin.StringMetric
  alias Akin.Primed

  @doc """
  Calculates the Hamming distance between 2 given strings.

  ## Examples
      iex> Akin.Hamming.compare(%Akin.Primed{string: "toned"}, %Akin.Primed{string: "roses"})
      3
      iex> Akin.Hamming.compare(%Akin.Primed{string: "toned"}, %Akin.Primed{string: "hamming"})
      nil
      iex> Akin.Hamming.compare(%Akin.Primed{string: "toned"}, %Akin.Primed{string: "toned"})
      0
  """
  def compare(left, right, _opts), do: compare(left, right)

  def compare(%Primed{string: left}, %Primed{string: right}) do
    compare(left, right)
  end

  def compare(left, right) when byte_size(left) == 0
  or byte_size(right) == 0
  or byte_size(left) != byte_size(right) do
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
