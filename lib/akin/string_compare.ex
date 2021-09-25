defmodule Akin.StringCompare do
  @moduledoc """
  This module compares two chunked strings for their similarity, using the
  “best partial” match. The "best partial" match refers to when two strings are
  of significantly different lengths. With the shorter string length as x and
  the longer string length as y, the score is determined by the best
  match achieved against the x-length string.

  From [seatgeek blogpost from 2011](https://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/).
  """
  use Akin.StringMetric
  alias Akin.{
    ChunkSet,
    SortedChunks,
    Strategy,
    SubstringComparison,
    Primed
  }

  @doc """
  Compares two binaries for their similarity and returns a float in the range of
  `0.0` and `1.0` where `0.0` means no similarity and `1.0` means exactly alike.

  ## Examples

      iex> StringCompare.compare("Oscar-Claude Monet", "monet, claude")
      0.95

      iex> String.jaro_distance("Oscar-Claude Monet", "monet, claude")
      0.6032763532763533
  """
  def compare(%Primed{string: left}, %Primed{string: right}) do
    compare(left, right)
  end

  def compare(left, right) when is_nil(left) or is_nil(right), do: 0

  def compare(left, right) when left == "" or right == "", do: 0

  def compare(left, right) when left in [nil, ""] or right in [nil, ""], do: nil

  def compare(left, right) do
    case Strategy.determine(left, right) do
      :standard -> standard_similarity(left, right)
      {:substring, scale} -> substring_similarity(left, right, scale)
    end
  end

  defp substring_similarity(left, right, substring_scale) do
    [
      SubstringComparison.similarity(left.string, right.string),
      SortedChunks.substring_similarity(left, right, substring_scale) * substring_scale,
      ChunkSet.compare(left, right) * substring_scale
    ]
    |> Enum.max()
  end

  defp standard_similarity(left, right) do
    [
      SortedChunks.compare(left, right),
      ChunkSet.compare(left, right)
    ]
    |> Enum.max()
  end
end
