defmodule Akin.Names do
  @moduledoc """
  Function specific to the comparison and matching of names. Returns matching names and metrics.
  """
  @behaviour Akin.Task
  import Akin.Util, only: [compose: 1, opts: 2, len: 1, r: 1]
  alias Akin.Helpers.InitialsComparison
  alias Akin.Corpus

  @weight 0.05
  @shortness_boost 0.0175

  @doc """
  Manage the steps of comparing two names. Collect metrics from the algorithms requested
  in the options or the default algorithms. Give weight to the consideration of initials
  and permutation of non-initialed name parts (i.e. "di constanzo" in "j p di constanzo".
  Weight is applied to the algorithm metrics.
  """
  def compare(left, right, opts \\ [])

  def compare(left, right, opts) when is_binary(left) and is_binary(right) do
    compare(compose(left), compose(right), opts)
  end

  def compare(%Corpus{} = left, %Corpus{} = right, opts) do
    weight = if InitialsComparison.similarity(left, right), do: @weight, else: @weight * -1
    score(left, right, opts, weight)
  end

  defp score(%Corpus{} = left, %Corpus{} = right, opts, weight) do
    metrics = Akin.compare(left, right)

    short_length = opts(opts, :short_length)
    initials_match? = if weight > 0, do: 1.0, else: 0.0

    score =
      calc(metrics, weight, short_length, len(right.string))
      |> Enum.map(fn {k, v} -> {k, r(v)} end)
      |> Keyword.put(:initials, initials_match?)

    %{scores: score}
  end

  defp calc(metrics, weight, len_cutoff, len) do
    Enum.map(metrics, fn {k, score} ->
      if len <= len_cutoff do
        return_calc(k, score + (weight + @shortness_boost))
      else
        return_calc(k, score + weight)
      end
    end)
  end

  defp return_calc(k, score) when score > 1, do: {k, 1.0}
  defp return_calc(k, score) when score < 0, do: {k, 0.0}
  defp return_calc(k, score), do: {k, Float.round(score, 2)}
end
