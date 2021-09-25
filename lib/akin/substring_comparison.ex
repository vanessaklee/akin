defmodule Akin.SubstringComparison do
  @moduledoc """
  This module offers the functionality of comparing strings of different
  lengths.

      iex> StringCompare.SubstringComparison.similarity("DEUTSCHLAND", "BUNDESREPUBLIK DEUTSCHLAND")
      0.9090909090909092

      iex> String.jaro_distance("DEUTSCHLAND", "BUNDESREPUBLIK DEUTSCHLAND")
      0.5399600399600399
  """

  @doc """
  The ratio function takes two strings as arguments and returns the substring
  similarity of those strings as a float between 0 and 1.

  The substring matching works by generating a list of equal substrings by means of
  [Myers Difference](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.4.6927),
  comparing these substrings with the Jaro-Winkler function against the shorter
  one of the two input strings and finally returning the maximum comparison
  value found.

  Let us assume as the input string the following: `"DEUTSCHLAND"` and
  `"BUNDESREPUBLIK DEUTSCHLAND"`. This yields the the matching substrings of
  `["DE", "U", "TSCHLAND"]`.

  We compare each one of them to the shorter one of the input strings:

      iex> String.jaro_distance("DE", "DEUTSCHLAND")
      0.7272727272727272

      iex> String.jaro_distance("U", "DEUTSCHLAND")
      0.6969696969696969

      iex> String.jaro_distance("TSCHLAND", "DEUTSCHLAND")
      0.9090909090909092

  Of all comparisons the highest value gets returned.
  """

  def similarity(left, right) when is_binary(left) and is_binary(right) do
    case String.length(left) <= String.length(right) do
      true -> do_similarity(left, right)
      false -> do_similarity(right, left)
    end
  end

  defp do_similarity(shorter, longer) do
    shorter
    |> get_matching_blocks(longer)
    |> Enum.map(&String.jaro_distance(shorter, &1))
    |> case do
      [] -> 0.0
      result -> Enum.max(result)
    end
  end

  defp get_matching_blocks("", _), do: []
  defp get_matching_blocks(_, ""), do: []

  defp get_matching_blocks(shorter, longer) do
    shorter
    |> String.myers_difference(longer)
    |> Enum.reduce([], fn
      {:eq, block_value}, accu -> [block_value | accu]
      _, accu -> accu
    end)
  end
end
