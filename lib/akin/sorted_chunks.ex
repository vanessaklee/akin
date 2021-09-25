defmodule Akin.SortedChunks do
  @moduledoc """
  In order to match strings whose order might be the only thing separating them
  the sorted chunks metric is applied. This strategy splits the strings on spaces,
  sorts the list of strings, joins them together again, and then compares them
  by applying the Jaro-Winkler distance metric.

  ## Examples

      iex> StringCompare.SortedChunks.standard_similarity("Oscar-Claude Monet", "Monet, Claude")
      0.8958333333333334

      iex> StringCompare.SortedChunks.substring_similarity("Oscar-Claude Monet", "Monet, Claude")
      1.0
  """
  use Akin.StringMetric
  alias Akin.{Primed, Strategy, SubstringComparison}

  # def compare(%Primed{chunks: left, stems: left_stems}, %Primed{chunks: right, stems: right_stems})
  def compare(%Primed{} = left, %Primed{} = right) do
    stems = compare(left.stems, right.stems)
    chunks = compare(left.chunks, right.chunks)
    Enum.max([stems, chunks])
  end

  def compare(left, right) when is_list(left) and is_list(right) do
    case Strategy.determine(left, right) do
      :standard -> similarity(left, right)
      {:substring, scale} -> substring_similarity(left, right, scale)
    end
    |> Enum.max()
  end

  def compare(left, right), do: compare([left], [right])

  def substring_similarity(left, right, scale) do
    similarity(left, right, SubstringComparison) * scale
  end

  defp similarity(left, right) do
    left =
      left
      |> Enum.sort()
      |> Enum.join()

    right =
      right
      |> Enum.sort()
      |> Enum.join()

    String.jaro_distance(left, right)
  end

  defp similarity(left, right, ratio_mod) do
    left =
      left
      |> Enum.sort()
      |> Enum.join()

    right =
      right
      |> Enum.sort()
      |> Enum.join()

    ratio_mod.similarity(left, right)
  end
end
