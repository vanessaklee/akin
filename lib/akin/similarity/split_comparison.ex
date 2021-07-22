defmodule Akin.Similarity.SplitNameDisambiguation do
  @moduledoc """
  This module compares to strings as names. It first splits eac string on the space character (" ").
  Each split string is put in tuple with the string itself and the first letter of that string. The
  tuples are compared for similarity.

  ## Getting started

  In order to compare two strings with each other do the following:

      iex> StringCompare.compare("Oscar-Claude Monet", "monet, claude")
      0.95

  ## Inner workings

  Imagine you had to [match some names](https://en.wikipedia.org/wiki/Record_linkage).

  Try to match the following list of painters:

    * `"Oscar-Claude Monet"`
    * `"Edouard Manet"`
    * `"Monet, Claude"`

  For a human it is easy to see that some of the names have just been flipped
  and that others are different but similar sounding.

  A first approrach could be to compare the strings with a string similarity
  function like the
  [Jaro-Winkler](https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance)
  function.

      iex> String.jaro_distance("Oscar-Claude Monet", "Monet, Claude")
      0.6032763532763533

      iex> String.jaro_distance("Oscar-Claude Monet", "Edouard Manet")
      0.6749287749287749

  This is not an improvement over exact equality.

  In order to improve the results this library uses two different approaches,
  `StringCompare.ChunkSet` and `StringCompare.SortedChunks`.

  ### Sorted chunks

  This approach yields good results when words within a string have been
  shuffled around. The strategy will sort all substrings by words and compare
  the sorted strings.

      iex> StringCompare.SortedChunks.substring_similarity("Oscar-Claude Monet", "Monet, Claude")
      1.0

      iex(4)> StringCompare.SortedChunks.substring_similarity("Oscar-Claude Monet", "Edouard Manet")
      0.6944444444444443
"""

  alias Akin.Similarity.{
    ChunkSet,
    JaroWinkler,
    Preprocessed,
    Preprocessor,
    SortedChunks,
    Strategy,
    SubstringComparison
  }

  @bias 0.95

  @doc """
  Compares two binaries for their similarity and returns a float in the range of
  `0.0` and `1.0` where `0.0` means no similarity and `1.0` means exactly alike.

  ## Examples

      iex> StringCompare.compare("Oscar-Claude Monet", "monet, claude")
      0.95

      iex> String.jaro_distance("Oscar-Claude Monet", "monet, claude")
      0.6032763532763533

  ## Preprocessing

  The ratio function expects either strings or the `StringCompare.Preprocessed` struct.

  When comparing a large list of strings against always the same string it is
  advisable to run the preprocessing once and pass the `StringCompare.Preprocessed` struct.
  That way you pay for preprocessing of the constant string only once.
  """
  def compare(left, right) when is_nil(left) or is_nil(right), do: 0
  def compare(left, right) when left == "" or right == "", do: 0
  def compare(left, right) when is_binary(left) and is_binary(right) do
    split_left = String.split(left)
    split_right = String.split(right)
    parts_compare(split_left, split_right)
  end

  def parts_compare(left, right) when is_list(left) and is_list(right) do
    count_left = Enum.count(left)
    count_right = Enum.count(right)

    # if count_left == count_right do
    #   tuple_left = Enum.reduce(left, [], fn n, acc ->
    #     [acc | [{String.first(n), n}]] |> List.flatten()
    #   end)
    #   tuple_right = Enum.reduce(right, [], fn n, acc ->
    #     [acc | [{String.first(n), n}]] |> List.flatten()
    #   end)

    #   if parts_compare(tuple_left, tuple_right, []) == 1 do
    #     1.0
    #   else
    #     # try reversing one of the names
    #     parts_compare(Enum.reverse(left), right)
    #   end
    # else
    #   # Akin.Similarity.StringCompare.compare(left, right)
    #   [first_left | rest_left] = left
    #   last_left = List.last(rest_left)
    #   middle_left = rest_left -- [last_left] |> Enum.join(" ") |> String.trim()

    #   [first_right | rest_right] = right
    #   last_right = List.last(rest_right)
    #   middle_right = rest_right -- [last_right] |> Enum.join(" ") |> String.trim()

    #   tuple_left = Enum.reduce([first_left, last_left], [], fn n, acc ->
    #     [acc | [{String.first(n), n}]] |> List.flatten()
    #   end)
    #   tuple_right = Enum.reduce([first_right, last_right], [], fn n, acc ->
    #     [acc | [{String.first(n), n}]] |> List.flatten()
    #   end)
    #   end_scores = parts_compare(tuple_left, tuple_right, [])
    #   IO.inspect(end_scores, label: "end scores")

    #   mid_scores = mid_compare(middle_left, middle_right)
    #   IO.inspect(mid_scores, label: "mid scores")
    # end

    # TODO then reverse one of the lists and compare that way

    IO.inspect(count_left, label: "count left")
    IO.inspect(count_right, label: "count right")

    cond do
      count_left == count_right ->
        tuple_left = Enum.reduce(left, [], fn n, acc ->
          [acc | [{String.first(n), n}]] |> List.flatten()
        end)
        tuple_right = Enum.reduce(right, [], fn n, acc ->
          [acc | [{String.first(n), n}]] |> List.flatten()
        end)

        if parts_compare(tuple_left, tuple_right, []) == 1 do
          1.0
        else
          # try reversing one of the names
          parts_compare(Enum.reverse(left), right)
        end
      count_left < count_right ->
        myers = String.myers_difference(Enum.join(left, " "), Enum.join(right, " "))
        inserts = Enum.reduce(myers, [], fn
          {:ins, block_value}, acc -> [String.trim(block_value) | acc]
          _, accu -> accu
        end)
        IO.inspect(inserts, label: "inserts")
        IO.inspect(left, label: "left")
        reduced_right = right -- inserts
        IO.inspect(reduced_right, label: "reduced_right")
        parts_compare(left, reduced_right)

      true ->
        # Akin.Similarity.StringCompare.compare(left, right)
        [first_left | rest_left] = left
        last_left = List.last(rest_left)
        middle_left = rest_left -- [last_left] |> Enum.join(" ") |> String.trim()

        [first_right | rest_right] = right
        last_right = List.last(rest_right)
        middle_right = rest_right -- [last_right] |> Enum.join(" ") |> String.trim()

        mid_scores = mid_compare(middle_left, middle_right)
        IO.inspect(mid_scores, label: "mid scores")

        tuple_left = Enum.reduce([first_left, last_left], [], fn n, acc ->
          [acc | [{String.first(n), n}]] |> List.flatten()
        end)
        tuple_right = Enum.reduce([first_right, last_right], [], fn n, acc ->
          [acc | [{String.first(n), n}]] |> List.flatten()
        end)
        end_scores = parts_compare(tuple_left, tuple_right, [])
        IO.inspect(end_scores, label: "end scores")

        Enum.sum([mid_scores, end_scores]) / 2
    end
  end


  # either string consists of only one letter each (i.e. an initial)
  # so only compare the first initials
  # TODO this should result in a low confidence in the score
  def parts_compare([{a, a_full} | a_rest], [{b, b_full} | b_rest], score) when a == a_full or b == b_full do
    s = if a == b, do: 1.0, else: 0
    parts_compare(a_rest, b_rest, [score | [s]] |> List.flatten())
  end
  def parts_compare([{_a, a_full} | a_rest], [{_b, b_full} | b_rest], score) do
    s = if a_full == b_full, do: 1.0, else: 0
    parts_compare(a_rest, b_rest, [score | [s]] |> List.flatten())
  end
  def parts_compare([], [], score), do: Enum.sum(score) / Enum.count(score)

  def mid_compare("", ""), do: 0.9
  def mid_compare("", _), do: 0.9
  def mid_compare(_, ""), do: 0.9
  def mid_compare(a, b), do: Akin.Similarity.StringCompare.compare(a, b)
end
