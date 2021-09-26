defmodule Akin.BagDistance do
  @moduledoc """
  This module contains the function to calculate the Bag Distance between two strings
  """
  @behaviour Akin.Task
  alias Akin.Corpus

  @spec compare(%Corpus{}, %Corpus{}) :: float()
  @spec compare(%Corpus{}, %Corpus{}, Keyword.t()) :: float()
  @doc """
  Calculates the Bag Distance between two given strings

  ## Examples

    iex> Akin.BagDistance.compare(%Akin.Corpus{string: "contact"}, %Akin.Corpus{string: "context"})
    0.7142857142857143
  """
  def compare(%Corpus{} = left, %Corpus{} = right, _opts), do: compare(left, right)

  def compare(%Corpus{string: left}, %Corpus{string: right}) do
    String.bag_distance(left, right)
  end
end
