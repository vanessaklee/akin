defmodule Akin do
  @moduledoc """
  Compare two strings for similarity. Options accepted in a keyword list (i.e. [ngram_size: 3]).

  1. `ngram_size` - number of contiguous letters to split strings into for comparison; used in Sorensen-Dice, Jaccard, NGram, Overlap, and Tversky algorithm. Default is 2.
  2. `level` - threshold for matching used in double metaphone algorithm. Default is "normal".
    * "strict": both encodings for each string must match
    * "strong": the primary encoding for each string must match
    * "normal": the primary encoding of one string must match either encoding of other string (default)
    * "weak":   either primary or secondary encoding of one string must match one encoding of other string
  3. `short_length`: only strings with a length greater than the `short_length` are analyzed by the algorithms which perform more accurately with long strings. Used by Sorensen-Dice, Jaccard, NGram, Overlap, and Tversky. Default is 8.
  4. `match_at`:
  """
  import Akin.Util, only: [modulize: 1, compose: 1, match_at: 1, short_length: 1, len: 1]
  alias Akin.Corpus
  alias Akin.NamesMetric

  NimbleCSV.define(CSVParse, separator: "\t")

  @opts [ngram_size: 2, level: "normal", short_length: 8, match_at: 0.9]

  @algorithms [
    "bag_distance",
    "substring_set",
    "sorensen_dice",
    "hamming",
    "jaccard",
    "jaro_winkler",
    "levenshtein",
    "metaphone",
    "double_metaphone",
    "substring_double_metaphone",
    "ngram",
    "overlap",
    "substring_sort",
    "tversky"
  ]

  @spec compare(binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: float()
  @doc """
  Compare two strings. Return map of algorithm metrics.

  Options accepted as a keyword list. If no options are given, default values will be used.
  """
  def compare(left, right, opts \\ @opts)

  def compare(left, right, opts) when is_binary(left) and is_binary(right) do
    compare(compose(left), compose(right), opts)
  end

  def compare(%Corpus{} = left, %Corpus{} = right, opts) do
    Enum.reduce(algorithms(opts), %{}, fn algorithm, acc ->
      Map.put(acc, algorithm, apply(modulize(algorithm), :compare, [left, right, opts]))
    end)
    |> Enum.reduce([], fn {k, v}, acc ->
      if is_nil(v) do
        acc
      else
        [{String.replace(k, ".", ""), v} | acc]
      end
    end)
    |> Enum.map(fn {k, v} -> {String.to_atom(k), r(v)} end)
    |> Enum.into(%{})
  end

  @spec compare_stems(binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: float()
  @doc """
  Compare two strings after stemming. Return map of algorithm. Options accepted as a keyword list.
  """
  def compare_stems(left, right, opts \\ @opts)

  def compare_stems(left, right, opts) when is_binary(left) and is_binary(right) do
    left = compose(left).stems |> Enum.join()
    right = compose(right).stems |> Enum.join()
    compare(left, right, opts)
  end

  @spec compare_using(binary(), binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: float()
  @doc """
  Compare two strings using a particular algorithm. Return a map of metrics. The algorithm
  name must be an atom (i.e. "jaro_winkler").

  Options accepted as a keyword list. If no options are given, the default values will be used.
  """
  def compare_using(algorithm, left, right, opts \\ @opts)

  def compare_using(algorithm, left, right, opts) when is_binary(left) and is_binary(right) do
    compare_using(algorithm, compose(left), compose(right), opts)
  end

  def compare_using(algorithm, %Corpus{} = left, %Corpus{} = right, opts) do
    apply(modulize(algorithm), :compare, [left, right, opts]) |> Float.round(2)
  end

  @spec smart_compare(binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: float()

  @doc """
  Compare two strings by first checking for white space within each string.
  If there is white space in either string, compare using only algorithms that prioritize
  substrings: "substring_set", "overlap", and "substring_sort". Otherwise, use
  only algoritms do not prioritize substrings.

  if either string is shorter than or equal to `length cutoff`, then N-Gram alogrithms are
  excluded (Sorensen-Dice, Jaccard, NGram, Overlap, and Tversky)

  Return a map of metrics for each algorithm used.

  Options accepted as a keyword list. If no options are given, the default values are used.
  """
  def smart_compare(left, right, opts \\ @opts)

  def smart_compare(left, right, opts) when is_binary(left) and is_binary(right) do
    smart_compare(compose(left), compose(right), opts)
  end

  def smart_compare(%Corpus{} = left, %Corpus{} = right, opts) do
    has_whitespace? = String.contains?(left.original, " ") or String.contains?(right.original, " ")
    cutoff = short_length(opts)
    short? = len(left.string) <= cutoff or len(right.string) <= cutoff

    unit = if has_whitespace? do
        "parts"
      else
        if short? do
          "whole"
        end
      end
    opts = Keyword.put(opts, :unit, unit)

    compare(left, right, opts)
  end

  @spec max(map()) :: float()
  @spec max(binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: list()
  @doc """
  Compare two strings. Return only the highest algorithm metrics. Options accepted as a keyword list.
  """
  def max(%{} = scores) do
    {_k, max_val} = Enum.max_by(scores, fn {_k, v} -> v end)
    Enum.filter(scores, fn {_k, v} -> v == max_val end)
  end

  def max(left, right, opts \\ @opts) do
    compare(left, right, opts)
    |> max()
  end

  @spec smart_max(binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: list()
  @doc """
  Compare two strings using smart_compare/3. Return only the highest algorithm metrics. Options accepted as a keyword list.
  """
  def smart_max(left, right, opts) do
    smart_compare(left, right, opts)
    |> max()
  end

  @spec match_names(binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: float()
  @doc """
  Compare a string against a list of strings.  Matches are determined by algorithem metrics equal to or higher than the
  `match_at` option. Return a list of strings that are a likely match.
  """
  def match_names(left, rights, opts \\ @opts)

  def match_names(left, rights, opts) when is_binary(left) and is_list(rights) do
    rights = Enum.map(rights, fn right -> compose(right) end)
    match_names(compose(left), rights, opts)
  end

  def match_names(%Corpus{} = left, rights, opts) do
    Enum.reduce(rights, [], fn right, acc ->
      case NamesMetric.compare(left, right, opts) do
        %{scores: scores} ->
          if Enum.any?(scores, fn {_algo, score} -> score > match_at(opts) end) do
            [right.original | acc]
          else
            acc
          end
        _ -> acc
      end
    end)
  end

  @spec match_names_metrics(binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: float()
  @doc """
  Compare a string against a list of strings. Matches are determined by algorithem metrics equal to or higher than the
  `match_at` option. Return a list of strings that are a likely match and their algorithm metrics.
  """
  def match_names_metrics(left, rights, opts \\ @opts)

  def match_names_metrics(left, rights, opts) when is_binary(left) and is_list(rights) do
    Enum.reduce(rights, [], fn right, acc ->
      case NamesMetric.compare(left, right, opts) do
        %{scores: scores} ->
          if Enum.any?(scores, fn {_algo, score} -> score > match_at(opts) end) do
            [%{left: left, right: right, metrics: scores, match: 1}  | acc]
          else
            [%{left: left, right: right, metrics: scores, match: 0}  | acc]
          end
        _ -> acc
      end
    end)
  end


  @spec algorithms() :: list()
  @spec algorithms(list() | Keyword.t()) :: list()
  @spec algorithms(binary(), binary(), list()) :: list()
  @doc """
  Return the default option values
  """
  def default_opts, do: @opts

  @doc """
  Return a list of algorithms.

  Accepts a list of algorithm names or a keyword list of options. Default returns all available.

  | Options |          |            | Default |
  | ------- | -------- | ---------- | ------- |
  | metric  | "string" | "phonetic" | both    |
  | unit    | "whole"  | "parts"    | both    |

  """
  def algorithms(), do: @algorithms

  def algorithms(opts) when is_list(opts) do
    metric = Keyword.get(opts, :metric)
    unit = Keyword.get(opts, :unit)
    algorithms = Keyword.get(opts, :algorithms) || []

    algorithms(metric, unit, algorithms)
  end

  def algorithms(_), do: @algorithms

  defp algorithms("string", "whole", []) do
    ["bag_distance", "levenshtein", "jaro_winkler", "jaccard", "hamming", "tversky", "sorensen_dice"]
  end

  defp algorithms("string", "parts", []) do
    ["substring_set", "substring_sort", "overlap", "ngram"]
  end

  defp algorithms("string", _, []) do
    algorithms("string", "whole", []) ++ algorithms("string", "parts", [])
  end

  defp algorithms("phonetic", "whole", []) do
    ["metaphone", "double_metaphone"]
  end

  defp algorithms("phonetic", "parts", []) do
    ["substring_double_metaphone"]
  end

  defp algorithms("phonetic", _, []) do
    algorithms("phonetic", "whole", []) ++ algorithms("phonetic", "parts", [])
  end

  defp algorithms(_, _, algorithms) when is_list(algorithms) do
    Enum.filter(algorithms, fn a -> a in @algorithms end)
  end

  defp algorithms(_, _, _) do
    @algorithms -- ["hamming"]
  end

  @doc """
  Round data types that can be rounded to 2 decimal points.
  """
  def r(v) when is_float(v), do: Float.round(v, 2)
  def r(v) when is_binary(v), do: Float.round(String.to_float(v), 2)
  def r(v) when is_integer(v), do: Float.round(v / 1, 2)
end
