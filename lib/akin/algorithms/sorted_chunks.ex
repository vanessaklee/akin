defmodule Akin.SortedChunks do
  @moduledoc """
  In order to match strings whose order might be the only thing separating them
  the sorted chunks metric is applied. This strategy splits the strings on spaces,
  sorts the list of strings, joins them together again, and then compares them
  by applying the Jaro-Winkler distance metric.

  ## Examples

      iex> StringCompare.SortedChunks.standard_similarity("Oscar-Claude Monet"}, %Akin.Primed{string: "Monet, Claude"})
      0.8958333333333334

      iex> StringCompare.SortedChunks.substring_similarity("Oscar-Claude Monet"}, %Akin.Primed{string: "Monet, Claude"})
      1.0
  """
  use Akin.StringMetric
  alias Akin.{Primed, Strategy, Helper.SubstringComparison}

  def compare(left, right, _opts), do: compare(left, right)

  def compare(%Primed{} = left, %Primed{} = right) do
    case Strategy.determine(left.string, right.string) do
      :standard ->
        stems = similarity(left.stems, right.stems)
        chunks = similarity(left.chunks, right.chunks)
        Enum.max([stems, chunks])
      {:substring, scale} ->
        stems = substring_similarity(left.stems, right.stems, scale)
        chunks = substring_similarity(left.chunks, right.chunks, scale)
        Enum.max([stems, chunks])
    end
  end

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
