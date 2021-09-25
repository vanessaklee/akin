defmodule Akin.BagDistance do
  @moduledoc """
  This module contains the function to calculate the Bag Distance between two strings
  """
  use Akin.StringMetric
  alias Akin.Primed

  @doc """
  Calculates the Bag Distance between two given strings

  ## Examples
      iex> Akin.BagDistance.compare(%Akin.Primed{string: "contact"}, %Akin.Primed{string: "context"})
      0.7142857142857143
  """
  def compare(left, right, _opts), do: compare(left, right)

  def compare(%Primed{string: left}, %Primed{string: right}) do
    String.bag_distance(left, right)
  end
end
