defmodule Akin.ChunkSet do
  @moduledoc """
  Functions for string comparsion where common words between the strings are compared in sets.
  """
  @behaviour Akin.Task
  alias Akin.{Corpus, Strategy, Helper.SubstringComparison}

  @spec compare(%Corpus{}, %Corpus{}) :: float()
  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  def compare(%Corpus{} = left, %Corpus{} = right, _opts), do: compare(left, right)

  def compare(%Corpus{string: left_string, set: left_set}, %Corpus{
        string: right_string,
        set: right_set
      }) do
    case Strategy.determine(left_string, right_string) do
      :standard -> similarity(left_set, right_set)
      {:substring, scale} -> substring_similarity(left_set, right_set, scale)
    end
  end

  @doc """
  Accepts two MapSets and determines common words.

  * `common_words = "claude monet"`
  * `common_words_plus_remaining_words_left = "claude monet oscar"`
  * `common_words_plus_remaining_words_right = "claude monet alice hoschedé was the wife of"`

  Return maximum ratio
  """
  def substring_similarity(left, right, scale) do
    similarity(left, right, SubstringComparison) * scale
  end

  defp similarity(left, right) do
    {common_words, common_words_plus_remaining_words_left,
     common_words_plus_remaining_words_right} = set_operations(left, right)

    [
      0.0,
      String.jaro_distance(common_words, common_words_plus_remaining_words_left),
      String.jaro_distance(common_words, common_words_plus_remaining_words_right),
      String.jaro_distance(
        common_words_plus_remaining_words_left,
        common_words_plus_remaining_words_right
      )
    ]
    |> Enum.max()
  end

  defp similarity(left, right, ratio_mod) do
    {common_words, common_words_plus_remaining_words_left,
     common_words_plus_remaining_words_right} = set_operations(left, right)

    [
      0.0,
      ratio_mod.similarity(common_words, common_words_plus_remaining_words_left),
      ratio_mod.similarity(common_words, common_words_plus_remaining_words_right),
      ratio_mod.similarity(
        common_words_plus_remaining_words_left,
        common_words_plus_remaining_words_right
      )
    ]
    |> Enum.max()
  end

  defp set_operations(left, right) do
    common_words = MapSet.intersection(left, right)

    common_words_string =
      common_words
      |> Enum.sort()
      |> Enum.join()

    [
      common_words_plus_remaining_words_left_string,
      common_words_plus_remaining_words_right_string
    ] =
      [left, right]
      |> Enum.map(fn x ->
        common_words_string <>
          (x
           |> MapSet.difference(common_words)
           |> Enum.sort()
           |> Enum.join())
      end)

    {
      common_words_string,
      common_words_plus_remaining_words_left_string,
      common_words_plus_remaining_words_right_string
    }
  end
end
