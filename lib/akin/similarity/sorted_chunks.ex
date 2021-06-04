defmodule Akin.Similarity.SortedChunks do
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
  alias Akin.Similarity.{
    Preprocessed,
    Preprocessor,
    SubstringComparison
  }

  def standard_similarity(left, right) when is_binary(left) and is_binary(right) do
    {processed_left, processed_right} = Preprocessor.process(left, right)
    standard_similarity(processed_left, processed_right)
  end

  def standard_similarity(%Preprocessed{chunks: left}, %Preprocessed{chunks: right}) do
    similarity(left, right)
  end

  def substring_similarity(left, right) when is_binary(left) and is_binary(right) do
    {processed_left, processed_right} = Preprocessor.process(left, right)
    substring_similarity(processed_left, processed_right)
  end

  def substring_similarity(%Preprocessed{chunks: left}, %Preprocessed{chunks: right}) do
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
