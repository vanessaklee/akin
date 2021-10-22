defmodule Akin.Helpers.InitialsComparison do
  @moduledoc """
  Function specific to the comparison and matching of names. Returns matching names and metrics.
  """
  import Akin.Util, only: [ngram_tokenize: 2]
  alias Akin.Corpus

  def similarity(%Corpus{} = left, %Corpus{} = right) do
    left_initials = initials(left) |> Enum.sort()
    right_initials = initials(right) |> Enum.sort()

    left_i_count = Enum.count(left_initials)
    right_i_count = Enum.count(right_initials)

    left_c_intials =
      cartesian_initials(left_initials, left.list)
      |> List.flatten()
      |> Enum.uniq()

    right_c_intials =
      cartesian_initials(right_initials, right.list)
      |> List.flatten()
      |> Enum.uniq()

    if String.contains?(left.original, ["-", "'"]) or String.contains?(right.original, ["-", "'"]) do
      case {left_i_count, right_i_count} do
        {li, ri} when li == ri -> left_initials == right_initials
        {li, ri} when li > ri ->
          case left_initials -- right_initials do
            [] -> true
            [_i] ->
              combined_hyphenation = right.list -- left.list
              full_permutations = get_permuations(left.list)
              combined_hyphenation -- full_permutations == []
            _ -> false
          end
        {li, ri} when li < ri ->
          case right_initials -- left_initials do
            [] -> true
            [_i] ->
              combined_hyphenation = left.list -- right.list
              full_permutations = get_permuations(right.list)
              combined_hyphenation -- full_permutations == []
            _ -> false
          end
      end
    else
      case {left_i_count, right_i_count} do
        {li, ri} when li == ri -> left_initials == right_initials
        {li, ri} when li > ri -> left_initials -- right_initials == []
        {li, ri} when li < ri -> right_initials -- left_initials == []
      end
    end
    |> cartesian_match(left_c_intials, right_c_intials)
    |> permutation_match(left.list, right.list)
  end

  def similarity(_, _, false), do: false

  defp initials(%Corpus{list: lists}) do
    Enum.map(lists, fn list -> String.at(list, 0) end)
  end

  defp initials(list) when is_list(list) do
    Enum.map(list, fn l -> String.at(l, 0) end)
  end

  defp initials(_), do: []

  defp actual_initials(list) do
    Enum.filter(list, fn l -> String.length(l) == 1 end)
  end

  def cartesian_initials(initials, list) do
    cartesian =
      for c <- 1..Enum.count(initials) do
        ngram_tokenize(Enum.join(initials, ""), c)
      end
      |> List.flatten()

    c = [cartesian | list] |> List.flatten() |> Enum.uniq()
    c -- initials
  end

  defp cartesian_match(true, _, _), do: true

  # do any of the cartesian products of the inital letters match?
  defp cartesian_match(false, left, right) do
    Enum.filter(left, fn l -> l in right end)
    |> Enum.count()
    |> Kernel.>(1)
  end

  defp permutation_match(true, _, _), do: true

  # do any of the permutations of the names match? (i.e. alfonso di costanzo & a dicostanzo)
  defp permutation_match(false, left, right) do
    left_ai = actual_initials(left)
    right_ai = actual_initials(right)

    left_permuations = get_permuations(left -- left_ai)
    right_permuations = get_permuations(right -- right_ai)

    Enum.filter(left_permuations, fn lp -> lp in right_permuations end)
    |> Enum.count()
    |> Kernel.>(1)
  end

  defp get_permuations(list) do
    Enum.reduce(list, [], fn l, acc ->
      ps = list -- [l]
      [Enum.map(ps, fn p -> l <> p end) | acc]
    end)
    |> List.flatten()
  end
end
