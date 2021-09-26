defmodule Akin.ChunkSet do
  @moduledoc """
  Functions for string comparsion where common words between the strings are compared in sets.

  Two sets

  #MapSet<["alice", "in", "wonderland"]>
  #MapSet<["adventures", "alice", "glass", "looking", "s", "the", "through"]>

  Commonality

  * `common_words = "alice"`
  * `common_words_plus_remaining_words_left = "aliceinwonderland"`
  * `common_words_plus_remaining_words_right = "aliceadventuresglasslookingsthethrough"`

  Ratio is based on difference in string length

  * if words are of similar in length according to Akin.Strategy.determine/2
    * ratio is String.jaro_distance
  * if words are of dissimilar in length according to Akin.Strategy.determine/2
    * ratio is Akin.SubstringComparison.similarity/2 * @ratio * scale (determined by Akin.Strategy)

  Strictness threshold is based on `opt` :threshold

  * "normal" returns average ratio
  * "weak" returns maximum ratio
  """
  @behaviour Akin.Task
  alias Akin.{Corpus, Strategy, Helper.SubstringComparison}

  @bias 0.95
  @default_threshold "normal"

  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  def compare(
        %Corpus{string: left_string, set: left_set},
        %Corpus{
          string: right_string,
          set: right_set
        },
        opts \\ []
      ) do
    threshold = Keyword.get(opts, :threshold) || @default_threshold

    case Strategy.determine(left_string, right_string) do
      :standard ->
        similarity(left_set, right_set) |> score(threshold)

      {:substring, scale} ->
        score =
          substring_similarity(left_set, right_set)
          |> score(threshold)

        score * @bias * scale
    end
  end

  defp score(scores, "weak"), do: Enum.max(scores)

  defp score(scores, _), do: Enum.sum(scores) / Enum.count(scores)

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
  end

  defp substring_similarity(left, right) do
    similarity(left, right, SubstringComparison)
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
