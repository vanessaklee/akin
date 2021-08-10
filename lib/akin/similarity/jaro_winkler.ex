defmodule Akin.Similarity.JaroWinkler do
  @moduledoc """
  Calculates the [Jaro-Winkler Distance](http://en.wikipedia.org/wiki/
  Jaro-Winkler_distance) between two strings.
  """
  # @behaviour Akin.StringMetric
  use Akin.StringMetric

  @doc """
  Calculates the Jaro-Winkler distance between two strings.
  ## Examples
      iex> Akin.Similarity.JaroWinkler.compare("abc", "")
      nil
      iex> Akin.Similarity.JaroWinkler.compare("abc", "xyz")
      0.0
      iex> Akin.Similarity.JaroWinkler.compare("compare me", "compare me")
      1.0
      iex> Akin.Similarity.JaroWinkler.compare("natural", "nothing")
      0.5714285714285714
  """
  def compare(left, right) when is_binary(left) and is_binary(right) do
    left_length = String.length(left)
    right_length = String.length(right)

    cond do
      left_length == 0 or right_length == 0 ->
        nil

      left == right ->
        1.0

      left_length > right_length ->
        score = score(right, left)
        modified_prefix = modify_prefix(right, left)
        score + modified_prefix * (1 - score) / 10

      true ->
        score = score(left, right)
        modified_prefix = modify_prefix(left, right)
        score + modified_prefix * (1 - score) / 10
    end
  end
  def compare(_, _), do: nil

  @doc """
  Score the distance between two strings using String.jaro/2.
  """
  def score(left, right) when is_binary(left) and is_binary(right) do
    left_length = String.length(left)
    right_length = String.length(right)

    if left_length == 0 or right_length == 0 do
      nil
    else
      String.jaro_distance(left, right)
    end
  end
  def score(_, _), do: nil

  @doc """
  Modifies the prefix scale, which gives a more favorable rating to strings
  that match from the beginning.
  """
  def modify_prefix(left, right) do
    modify_prefix(left, right, 0, Enum.min([4, String.length(left)]))
  end

  def modify_prefix(left, right, prefix_length, last_character) do
    if prefix_length < last_character &&
       String.at(left, prefix_length) == String.at(right, prefix_length) do
      modify_prefix(left, right, prefix_length + 1, last_character)
    else
      prefix_length
    end
  end
end
