defmodule Akin.DoubleMetaphone do
  @moduledoc """
  Compares two values phonetically and returns a boolean of whether they match
  using the match_level in opts. Match calculated using the
  [Double Metaphone Phonetic Algorithm](https://xlinux.nist.gov/dads/HTML/doubleMetaphone.html).
  """
  @behaviour Akin.Task
  import Akin.Util, only: [compose: 1]
  alias Akin.Corpus
  alias Akin.Metaphone.Double

  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  def compare(left, right, opts \\ Akin.default_opts())

  def compare(left, right, opts) when is_binary(left) and is_binary(right) do
    compare(compose(left), compose(right), opts)
  end

  def compare(%Corpus{string: left}, %Corpus{string: right}, opts) do
    match_level = Keyword.get(opts, :match_level)
    if Double.compare(left, right, match_level), do: 1.0, else: 0.0
  end

  defmodule Chunks do
    @moduledoc """
    Chunk the search terms into lists split by white space and compare the cartesian product of the lists.

    ## Examples

      iex> left = "Alice Liddel"
      iex> right = "Liddel, Alice"
      iex> Akin.compare_using("double_metaphone._chunks", left, right)
      1.0
      iex> right = "Alice P Liddel"
      iex> Akin.compare_using("double_metaphone._chunks", left, right)
      1.0
      iex> right = "Alice Hargreaves"
      iex> Akin.compare_using("double_metaphone._chunks", left, right)
      0.5
      iex> right = "Alice's Adventures in Wonderland"
      iex> Akin.compare_using("double_metaphone._chunks", left, right)
      0.5
    """
    @behaviour Akin.Task

    @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
    @doc """
    Compares two lists of values phonetically and returns a boolean of whether they match
    reducing all possible matching match_levels.
    """
    def compare(left, right, opts \\ Akin.default_opts())

    def compare(%Corpus{chunks: left}, %Corpus{chunks: right}, opts) when is_list(opts) do
      Double.scored_chunked_compare(left, right, opts) / 1.0
    end
  end
end
