defmodule Akin.Names do
  @moduledoc"""
  Function specific to the comparison and matching of names.
  """
  @behaviour Akin.Task
  import Akin.Util, only: [compose: 1, initials: 1, match_left_initials?: 1, eq?: 2]
  alias Akin.Corpus

  @boost 0.075

  @spec compare(binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: float()
  @doc """
  Manage the comparison steps of comparing two names. If the left string includes initials,
  they may have a lower score when compared to the full name if it exists in the right string.
  If initials exist in the left name, perform a separate comparison of the initals and the
  chunks of the right string. There must be an exact match of each initial against the first
  character of one of the chunks. Metrics are are result of a smart comparison of
  all remaining non-initial chunks of the left Corpus and the original right Corpus.

  If all the initials match to something in the right chunks, metrics are boosted by @boost.
  """
  def compare(left, right, opts \\ [])

  def compare(left, right, opts) when is_binary(left) and is_binary(right) do
    compare(compose(left), compose(right), opts)
  end

  def compare(%Corpus{} = left, %Corpus{} = right, opts) do
    compare(left, right, opts, match_left_initials?(opts))
  end

  def compare(%Corpus{} = left, %Corpus{} = right, opts, true) do
    left_initials = initials(left)
    left_chunks = (left.chunks -- left_initials)
    chunks = (right.chunks -- left_chunks)

    matching_initials = match_initials(left_initials, chunks)

    # left = %Corpus{left | chunks: left_chunks}
    metrics = Akin.smart_max(left, right, opts)

    score(metrics, matching_initials)
  end

  def compare(%Corpus{} = left, %Corpus{} = right, opts, false) do
    Akin.smart_max(left, right, opts)
  end

  defp score(metrics, matches) when is_nil(matches) or matches <= 0, do: metrics
  defp score(metrics, _) do
    Enum.map(metrics, fn {k, score} ->
      {k, score + (score * @boost)}
    end)
  end

  defp match_initials([], _chunks), do: nil
  defp match_initials(initials, chunks) do
    chunks
    |> Enum.filter(fn c ->
      String.at(c, 0) in initials
    end)
    |> Enum.count()
    |> eq?(Enum.count(initials))
  end
end
