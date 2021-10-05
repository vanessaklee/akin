defmodule Akin.Names do
  @moduledoc"""
  Function specific to the comparison and matching of names.
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
    compare(left, right, opts, boost_initials?(opts))
  end

  def compare(%Corpus{} = left, %Corpus{} = right, opts, true) do
    matching_initials = match_initials(left, right)
    score(left, right, opts, matching_initials)
  end

  def compare(%Corpus{} = left, %Corpus{} = right, opts, false) do
    Akin.smart_max(left, right, opts)
  end

  defp score(left, right, opts, matches) do
    metrics = Akin.smart_max(left, right, opts)
    percent = matches/Enum.count(right.list)

    short_length = short_length(opts)
    calc(metrics, matches, percent, short_length, len(right.string))
  end

  defp calc(metrics, matches, _, _, _) when is_nil(matches) or matches <= 0, do: metrics

  defp calc(metrics, _, percent, len_cutoff, len) do
    boost = @boost * percent
    Enum.map(metrics, fn {k, score} ->
      if len <= len_cutoff do
        {k, score + (score * (boost + @shortness_boost))}
      else
        {k, score + (score * boost)}
      end
    end)
  end

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
  end

  defp form_initials(list) do
    initials = get_initials(list)
    for c <- 0..Enum.count(initials) do
        ngram_tokenize(Enum.join(initials, ""), c)
      end
      |> flat_and_uniq()
  end
end
