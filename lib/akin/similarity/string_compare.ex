defmodule Akin.Similarity.StringCompare do
  @moduledoc """
  This module compares two strings for their similarity and uses multiple
  approaches to get high quality results.

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

  ### Chunkset

  The chunkset approach is best in scenarios when the strings contain other
  substrings that are not relevant to what is being searched for.

      iex> StringCompare.ChunkSet.standard_similarity("Claude Monet", "Alice Hoschedé was the wife of Claude Monet")
      1.0

  ### Substring comparison

  Should one of the strings be much longer than the other the library will
  attempt to compare matching substrings only.

  ## Credits

  This library is inspired by a [seatgeek blogpost from 2011](https://chairnerd.seatgeek.com/fuzzywuzzy-fuzzy-string-matching-in-python/).
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
    {processed_left, processed_right} = Preprocessor.process(left, right)

    compare(processed_left, processed_right)
  end

  def compare(left, right) when left in [nil, ""] or right in [nil, ""], do: nil
  def compare(%Preprocessed{} = left, %Preprocessed{} = right) do
    case Strategy.determine_strategy(left, right) do
      :standard -> standard_similarity(left, right)
      {:substring, scale} -> substring_similarity(left, right, scale)
    end
  end

  defp substring_similarity(
         %Preprocessed{} = left,
         %Preprocessed{} = right,
         substring_scale
       ) do
    [
      JaroWinkler.compare(left.string, right.string),
      SubstringComparison.similarity(left.string, right.string),
      SortedChunks.substring_similarity(left, right) * @bias * substring_scale,
      ChunkSet.substring_similarity(left, right) * @bias * substring_scale
    ]
    |> Enum.max()
  end

  defp standard_similarity(%Preprocessed{} = left, %Preprocessed{} = right) do
    [
      JaroWinkler.compare(left.string, right.string),
      SortedChunks.standard_similarity(left, right) * @bias,
      ChunkSet.standard_similarity(left, right) * @bias
    ]
    |> Enum.max()
  end
end
