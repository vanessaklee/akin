defmodule Akin.SubstringDoubleMetaphone do
  @moduledoc """
  Tokenize the search terms into lists split by white space and compare the cartesian product of the lists.

  ## Examples

    iex> left = "Alice Liddel"
    iex> right = "Liddel, Alice"
    iex> Akin.compare_using("substring_double_metaphone", left, right)
    1.0
    iex> right = "Alice P Liddel"
    iex> Akin.compare_using("substring_double_metaphone", left, right)
    1.0
    iex> right = "Alice Hargreaves"
    iex> Akin.compare_using("substring_double_metaphone", left, right)
    0.5
    iex> right = "Alice's Adventures in Wonderland"
    iex> Akin.compare_using("substring_double_metaphone", left, right)
    0.5
  """
  @behaviour Akin.Task
  alias Akin.Corpus
  alias Akin.Metaphone.Double

  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  @doc """
  Compares two lists of values phonetically and returns a boolean of whether they match
  reducing all possible matching match_levels.
  """
  def compare(left, right, opts \\ [])

  def compare(%Corpus{list: left}, %Corpus{list: right}, opts) when is_list(opts) do
    Double.substring_compare(left, right, opts) / 1.0
  end
end
