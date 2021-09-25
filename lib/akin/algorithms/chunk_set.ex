defmodule Akin.ChunkSet do
  @moduledoc """
  Functions for string comparsion where common words between the strings are compared in the
  following sets.

    * `common_words = "claude monet"`
    * `common_words_plus_remaining_words_left = "claude monet oscar"`
    * `common_words_plus_remaining_words_right = "claude monet alice hoschedé was the wife of"`

  Return maximum ratio
  ## Examples

      iex> StringCompare.ChunkSet.standard_similarity("oscar claude monet", "alice hoschedé was the wife of claude monet")
      0.8958333333333334

      iex> StringCompare.ChunkSet.substring_similarity("oscar claude monet", "alice hoschedé was the wife of claude monet")
      1.0
  """
  use Akin.StringMetric
  alias Akin.{Primed, Strategy, Helper.SubstringComparison}


  def compare(left, right, _opts), do: compare(left, right)

  def compare(%Primed{} = left, %Primed{} = right) do
    case Strategy.determine(left.string, right.string) do
      :standard -> similarity(left.set, right.set)
      {:substring, scale} -> substring_similarity(left.set, right.set, scale)
    end
  end

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
