defmodule Akin.Similarity.BagDistance do
  @moduledoc """
  This module contains the function to calculate the Bag Distance between two strings
  """
  # @behaviour Akin.StringMetric
  use Akin.StringMetric

  @doc """
  Calculates the Bag Distance between two given strings

  ## Examples
      iex> Akin.Similarity.BagDistance.compare("contact", "context")
      0.7142857142857143
  """
  def compare(left, right), do: String.bag_distance(left, right)
end
