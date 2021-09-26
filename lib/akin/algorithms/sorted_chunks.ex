defmodule Akin.SortedChunks do
  @moduledoc """
  Use Chunk Sorting to compare two strings using substrings.

  Ratio is based on difference in string length

  * if words are of similar in length according to Akin.Strategy.determine/2
    * ratio is String.jaro_distance
  * if words are of dissimilar in length according to Akin.Strategy.determine/2
    * ratio is Akin.SubstringComparison.similarity/2 * @ratio * scale (determined by Akin.Strategy)
  """
  @behaviour Akin.Task
  alias Akin.{Corpus, Strategy, Helper.SubstringComparison}

  @bias 0.95

  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  @doc """
  This strategy splits the strings on spaces, sorts the list of strings, joins them
  together again, and then compares them by applying the Jaro-Winkler distance metric.

  ## Examples

    iex> Akin.SortedChunks.compare(Akin.Util.compose("Alice in Wonderland"), Akin.Util.compose("Alice's Adventures in Wonderland"))
    0.63

    iex> StringCompare.SortedChunks.substring_similarity("Oscar-Claude Monet"}, %Akin.Corpus{string: "Monet, Claude"}, Akin.Util.compose("Alice's Adventures in Wonderland"))
    1.0
  """
  def compare(%Corpus{} = left, %Corpus{} = right, _opts \\ []) do
    case Strategy.determine(left.string, right.string) do
      :standard ->
        stems = similarity(left.stems, right.stems)
        chunks = similarity(left.chunks, right.chunks)
        Enum.max([stems, chunks])

      {:substring, scale} ->
        stems = substring_similarity(left.stems, right.stems)
        chunks = substring_similarity(left.chunks, right.chunks)
        Enum.max([stems, chunks]) * @bias * scale
    end
  end

  defp substring_similarity(left, right) do
    similarity(left, right, SubstringComparison)
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
