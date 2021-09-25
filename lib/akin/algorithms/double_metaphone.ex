defmodule Akin.DoubleMetaphone do
  @moduledoc """
  Compares two values phonetically and returns a boolean of whether they match
  using the threshold in opts. Match calculated using the
  [Double Metaphone Phonetic Algorithm](https://xlinux.nist.gov/dads/HTML/doubleMetaphone.html).
  """
  use Akin.StringMetric
  alias Akin.Primed
  alias Akin.Metaphone.Double

  @default_threshold "normal"

  def compare(left, right), do: compare(left, right, @default_threshold)

  def compare(%Primed{string: left}, %Primed{string: right}, opts) when is_list(opts) do
    threshold = Keyword.get(opts, :threshold)
    compare(left, right, threshold)
  end

  def compare(left, right, treshold) do
    if Double.compare(left, right, treshold), do: 1, else: 0
  end

  defmodule Chunks do
    use Akin.StringMetric

    @doc """
    Compares two lists of values phonetically and returns a boolean of whether they match
    reducing all possible matching thresholds.
    """
    def compare(left, right, _opts), do: compare(left, right)

    def compare(%Primed{chunks: left}, %Primed{chunks: right}) do
      if Double.scored_chunked_compare(left, right), do: 1, else: 0
    end
  end
end
