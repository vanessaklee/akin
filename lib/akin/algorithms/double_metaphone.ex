defmodule Akin.DoubleMetaphone do
  @moduledoc """
  Compares two values phonetically and returns a boolean of whether they match
  using the level in opts. Match calculated using the
  [Double Metaphone Phonetic Algorithm](https://xlinux.nist.gov/dads/HTML/doubleMetaphone.html).
  """
  @behaviour Akin.Task
  import Akin.Util, only: [level: 1]
  alias Akin.Corpus
  alias Akin.Metaphone.Double

  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  @doc """
  Compare two strings using the double metaphoen algorithm
  """
  def compare(left, right, opts \\ [])

  def compare(%Corpus{string: left}, %Corpus{string: right}, opts) do
    if Double.compare(left, right, level(opts)), do: 1.0, else: 0.0
  end

  def compare(_, _, _), do: 0.0
end
