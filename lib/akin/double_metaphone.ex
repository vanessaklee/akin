defmodule Akin.DoubleMetaphone do
  @moduledoc """
  Calculates the [Double Metaphone Phonetic Algorithm](https://xlinux.nist.gov/dads/HTML/doubleMetaphone.html)
  metric of two strings.
  """
  alias Akin.Primed

  defmodule Normal do
    use Akin.StringMetric
    alias Akin.Metaphone.Double
    @doc """
      Compares two values phonetically and returns a boolean of whether they match
      using the default match threshold ("normal").
    """
    def compare(%Primed{string: left}, %Primed{string: right}) do
      if Double.compare(left, right), do: 1, else: 0
    end
  end

  defmodule Weak do
    use Akin.StringMetric
    alias Akin.Metaphone.Double

    @doc """
      Compares two values phonetically and returns a boolean of whether they match
      using the strict match threshold ("strict").
    """
    def compare(left, right), do: if Double.compare(left, right, "strict"), do: 1, else: 0
  end

  defmodule Strict do
    use Akin.StringMetric
    alias Akin.Metaphone.Double

    @doc """
      Compares two values phonetically and returns a boolean of whether they match
      using the weak match threshold ("weak").
    """
    def compare(left, right), do: if Double.compare(left, right, "weak"), do: 1, else: 0
  end
end
