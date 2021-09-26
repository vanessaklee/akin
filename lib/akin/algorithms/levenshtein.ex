defmodule Akin.Levenshtein do
  @moduledoc """
  Compare two strings for their Levenshtein score.
  """
  @behaviour Akin.Task
  alias Akin.Corpus

  @spec compare(%Corpus{}, %Corpus{}) :: float()
  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  @doc """
  The score is determined by finding the edit
  distance: the minimum number of single-character edits needed to change one word into the other.
  The distance is substracted from 1.0 and then divided by the longest length between the two strings.
  Result is rounded to the tenths.
  """
  def compare(%Corpus{string: left}, %Corpus{string: right}, _opts), do: compare(left, right)

  def compare(string, string), do: 1

  def compare(string, []), do: length(string)

  def compare([], string), do: length(string)

  def compare(left, right) when is_binary(left) and is_binary(right) do
    distance = compare(String.graphemes(left), String.graphemes(right))
    1.0 - distance / Enum.max([String.length(left), String.length(right)])
  end

  def compare(left, right)
      when is_list(left) and is_list(right) do
    rec_lev(left, right, :lists.seq(0, length(right)), 1)
  end

  defp rec_lev([src_head | src_tail], right, distlist, step) do
    rec_lev(src_tail, right, lev_dist(right, distlist, src_head, [step], step), step + 1)
  end

  defp rec_lev([], _right, distlist, _step) do
    List.last(distlist)
  end

  defp lev_dist(
         [right_head | right_tail],
         [distlist_head | distlist_tail],
         left_char,
         new_distlist,
         last_dist
       )
       when distlist_tail > 0 do
    min =
      Enum.min([
        last_dist + 1,
        hd(distlist_tail) + 1,
        distlist_head + delta(right_head, left_char)
      ])

    lev_dist(right_tail, distlist_tail, left_char, new_distlist ++ [min], min)
  end

  defp lev_dist([], _, _, new_distlist, _), do: new_distlist

  defp delta(a, a), do: 0

  defp delta(_a, _b), do: 1
end
