defmodule Akin.NamesMetric do
  @moduledoc"""
  Function specific to the comparison and matching of names. Returns matching names and metrics.
  """
  @behaviour Akin.Task
  import Akin.Util
  alias Akin.Corpus

  @boost 0.075
  @shortness_boost 0.015

  @spec compare(binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: float()
  @doc """
  Manage the comparison steps of comparing two names. If the left string includes initials,
  they may have a lower score when compared to the full name if it exists in the right string.
  If initials exist in the left name, perform a separate comparison of the initals and the
  set of the right string. There must be an exact match of each initial against the first
  character of one of the set. Metrics are are result of a smart comparison of
  all remaining non-initial set of the left Corpus and the original right Corpus.

  If all the initials match to something in the right set, metrics are boosted by @boost.
  """
  def compare(left, right, opts \\ [])

  def compare(left, right, opts) when is_binary(left) and is_binary(right) do
    compare(compose(left), compose(right), opts)
  end

  def compare(%Corpus{} = left, %Corpus{} = right, opts) do
    boost? = boost_initials?(opts)
    compare(left, right, Keyword.delete(opts, :boost_initials), boost?)
  end

  def compare(_, _, _), do: nil

  def compare(%Corpus{} = left, %Corpus{} = right, opts, true) do
    matching_initials = match_initials(left, right)
    score(left, right, Keyword.delete(opts, :boost_initials), matching_initials)
  end

  def compare(%Corpus{} = left, %Corpus{} = right, opts, false) do
    opts = Keyword.put(opts, :algorithms, algorithms())
    %{scores: Akin.compare(left, right, opts)}
    # Akin.max(left, right, opts)
    # Akin.smart_max(left, right, opts)
  end

  defp score(%Corpus{} = left, %Corpus{} = right, opts, matches) do
    opts = Keyword.put(opts, :algorithms, algorithms())
    metrics = Akin.compare(left, right, opts)
    # metrics = Akin.smart_compare(left, right, opts)
    # max = Akin.max(metrics)
    percent = matches/Enum.count(right.list)

    short_length = short_length(opts)
    score = calc(metrics, matches, percent, short_length, len(right.string))
      |> Enum.map(fn {k, v} -> {k, Akin.r(v)} end)
    %{scores: score}
  end

  defp calc(metrics, matches, _, _, _) when is_nil(matches) or matches <= 0, do: metrics

  defp calc(metrics, _, percent, len_cutoff, len) do
    boost = @boost * percent
    Enum.map(metrics, fn {k, score} ->
      if len <= len_cutoff do
        return_calc(k, score + (score * (boost + @shortness_boost)))
      else
        return_calc(k, score + (score * boost))
      end
    end)
  end

  defp return_calc(k, score) when score > 1, do: {k, 1.0}
  defp return_calc(k, score), do: {k, score}

  defp match_initials(left, right) do
    initials = form_initials(left)
    list = right.list

    match(initials, list)
  end

  defp match([], _list), do: nil
  defp match(initials, list) do
    list
    |> Enum.filter(fn c ->
      String.at(c, 0) in initials
    end)
    |> Enum.count()
    # |> div(Enum.count(initials))
  end

  defp form_initials(list) do
    initials = get_initials(list)
    for c <- 0..Enum.count(initials) do
        ngram_tokenize(Enum.join(initials, ""), c)
      end
      |> flat_and_uniq()
  end

  defp algorithms() do
    Akin.algorithms() -- ["hamming"]
  end
end
