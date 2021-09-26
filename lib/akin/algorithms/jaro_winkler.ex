defmodule Akin.JaroWinkler do
  @moduledoc """
  Calculates the [Jaro-Winkler Distance](http://en.wikipedia.org/wiki/
  Jaro-Winkler_distance) between two strings.
  """
  @behaviour Akin.Task
  alias Akin.Corpus

  @spec compare(%Corpus{}, %Corpus{}) :: float()
  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  @doc """
  Calculates the Jaro-Winkler distance between two strings.

  ## Examples

    iex> Akin.JaroWinkler.compare(%Akin.Corpus{string: "abc"}, %Akin.Corpus{string: ""})
    0.0
    iex> Akin.JaroWinkler.compare(%Akin.Corpus{string: "abc"}, %Akin.Corpus{string: "xyz"})
    0.0
    iex> Akin.JaroWinkler.compare(%Akin.Corpus{string: "compare me"}, %Akin.Corpus{string: "compare me"})
    1.0
    iex> Akin.JaroWinkler.compare(%Akin.Corpus{string: "natural"}, %Akin.Corpus{string: "nothing"})
    0.5714285714285714
  """
  def compare(%Corpus{string: left}, %Corpus{string: right}, _opts), do: compare(left, right)

  def compare(%Corpus{string: left}, %Corpus{string: right}) do
    compare(left, right)
  end

  def compare(left, right) when is_binary(left) and is_binary(right) do
    left_length = String.length(left)
    right_length = String.length(right)

    cond do
      left_length == 0 or right_length == 0 ->
        0.0

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

  @spec score(binary(), binary()) :: integer()
  @doc """
  Score the distance between two strings using String.jaro/2.
  """
  def score(left, right) when is_binary(left) and is_binary(right) do
    left_length = String.length(left)
    right_length = String.length(right)

    if left_length == 0 or right_length == 0 do
      0
    else
      String.jaro_distance(left, right)
    end
  end

  def score(_, _), do: nil

  @spec score(binary(), binary()) :: integer()
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
