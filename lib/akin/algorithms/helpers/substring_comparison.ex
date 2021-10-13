defmodule Akin.Helper.SubstringComparison do
  @moduledoc """
  Functions to compare strings of different lengths.
  """

  @doc """
  Determine the substring similarity of two strings as a float between 0 and 1.
  """
  def similarity(left, right) when is_binary(left) and is_binary(right) do
    case String.length(left) <= String.length(right) do
      true -> do_similarity(left, right)
      false -> do_similarity(right, left)
    end
  end

  defp do_similarity(shorter, longer) do
    shorter
    |> get_matching_blocks(longer)
    |> Enum.map(&String.jaro_distance(shorter, &1))
    |> case do
      [] ->
        0.0

      result ->
        Enum.max(result)
    end
  end

  defp get_matching_blocks("", _), do: []
  defp get_matching_blocks(_, ""), do: []

  defp get_matching_blocks(shorter, longer) do
    shorter
    |> String.myers_difference(longer)
    |> Enum.reduce([], fn
      {:eq, block_value}, accu -> [block_value | accu]
      _, accu -> accu
    end)
  end
end
