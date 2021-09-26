defmodule Akin.DoubleMetaphone do
  @moduledoc """
  Compares two values phonetically and returns a boolean of whether they match
  using the threshold in opts. Match calculated using the
  [Double Metaphone Phonetic Algorithm](https://xlinux.nist.gov/dads/HTML/doubleMetaphone.html).
  """
  @behaviour Akin.Task
  alias Akin.Corpus
  alias Akin.Metaphone.Double

  @default_threshold "normal"

  @spec compare(%Corpus{}, %Corpus{}) :: float()
  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  def compare(left, right), do: compare(left, right, @default_threshold)

  def compare(%Corpus{string: left}, %Corpus{string: right}, opts) when is_list(opts) do
    threshold = Keyword.get(opts, :threshold) || @default_threshold
    compare(left, right, threshold)
  end

  def compare(left, right, treshold) do
    if Double.compare(left, right, treshold), do: 1.0, else: 0.0
  end

  defmodule Chunks do
    @behaviour Akin.Task

    @doc """
    Compares two lists of values phonetically and returns a boolean of whether they match
    reducing all possible matching thresholds.
    """
    def compare(%Corpus{} = left, %Corpus{} = right, _opts), do: compare(left, right)

    def compare(%Corpus{chunks: left}, %Corpus{chunks: right}) do
      Double.scored_chunked_compare(left, right) / 1.0
    end
  end
end
