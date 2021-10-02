defmodule Akin do
  @moduledoc """
  Compare two strings for similarity.

  Options can be provided in a keyword list (i.e. [ngram_size: 3]). The available options are:

  1. `ngram_size` - number of contiguous letters to split strings into for comparison; used in Sorensen-Dice, Jaccard, NGram, Overlap, and Tversky algorithm. Default is 2.
  2. `match_level` - threshold for matching used in double metaphone algorithm. Default is "normal".
    * "strict": both encodings for each string must match
    * "strong": the primary encoding for each string must match
    * "normal": the primary encoding of one string must match either encoding of other string (default)
    * "weak":   either primary or secondary encoding of one string must match one encoding of other string
  3. `length_cutoff`: only strings with a length greater than the `length_cutoff` are analyzed by the algorithms which perform more accurately with long strings. Used by Sorensen-Dice, Jaccard, NGram, Overlap, and Tversky. Default is 8.
  4. `match_cutoff`:
  """
  import Akin.Util, only: [modulize: 1, compose: 1, match_cutoff: 1, length_cutoff: 1, len: 1]
  alias Akin.Corpus
  alias Akin.Names
  alias Akin.NamesMetric

  NimbleCSV.define(CSVParse, separator: "\t")

  @opts [ngram_size: 2, match_level: "normal", length_cutoff: 8, match_cutoff: 0.9]

  @algorithms [
    "bag_distance",
    "chunk_set",
    "sorensen_dice",
    "hamming",
    "jaccard",
    "jaro_winkler",
    "levenshtein",
    "metaphone",
    "double_metaphone",
    "double_metaphone._chunks",
    "ngram",
    "overlap",
    "sorted_chunks",
    "tversky"
  ]

  @spec compare(binary() | %Corpus{}, binary() | %Corpus{}, list(), keyword()) :: float()
  @doc """
  Compare two strings using given or default algorithms. Return map of metrics for the algorithms
  used.

  Options accepted as a keyword list. If no options are given, the default values will be used.
  Also accepts a list of algorithms to use for comparison, otherwise the default list is used
  (see `algorithms/0`).
  """
  def compare(left, right, algorithms \\ [], opts \\ @opts)

  def compare(left, right, algorithms, opts) when is_binary(left) and is_binary(right) do
    compare(compose(left), compose(right), algorithms, opts)
  end

  def compare(%Corpus{} = left, %Corpus{} = right, [], opts) do
    compare(left, right, algorithms([short: false, has_whitespace: false]), opts)
  end

  def compare(%Corpus{} = left, %Corpus{} = right, algorithms, opts) do
    Enum.reduce(algorithms, %{}, fn algorithm, acc ->
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

  @spec compare_stems(binary() | %Corpus{}, binary() | %Corpus{}, list(), keyword()) :: float()
  @doc """
  Compare two strings after stemming using given or default algorithms. Return map of metics for each
  algorithm used.

  Options accepted as a keyword list. If no options are given, the default values will be used.
  Also accepts a list of algorithms to use for comparison, otherwise the default list is used
  (see `algorithms/0`).
  """
  def compare_stems(left, right, algorithms \\ [], opts \\ @opts)

  def compare_stems(left, right, algorithms, opts) when is_binary(left) and is_binary(right) do
    left = compose(left).stems |> Enum.join()
    right = compose(right).stems |> Enum.join()
    compare(left, right, algorithms, opts)
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
  substrings and/or chunks: "chunk_set", "overlap", and "sorted_chunks". Otherwise, use
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
    cutoff = length_cutoff(opts)
    short? = len(left.string) <= cutoff or len(right.string) <= cutoff

    algorithms = algorithms([short: short?, has_whitespace: has_whitespace?])
    compare(left, right, algorithms, opts)
  end

  @spec max(map()) :: float()
  @spec max(binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: list()
  @doc """
  Compare two strings using all algorithms. Return only the highest algorithm metrics.

  Options accepted as a keyword list. If no options are given, the default values will be used.
  Also accepts a list of algorithms to use for comparison, otherwise the default list is used
  (see `algorithms/0`).
  """
  def max(%{} = scores) do
    {_k, max_val} = Enum.max_by(scores, fn {_k, v} -> v end)
    Enum.filter(scores, fn {_k, v} -> v == max_val end)
  end

  def max(left, right, algorithms \\ [], opts \\ @opts) do
    compare(left, right, algorithms, opts)
    |> max()
  end

  @spec smart_max(binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: list()
  @doc """
  Compare two strings using smart_compare/3. Return only the highest algorithm metrics.

  Options accepted as a keyword list. If no options are given, the default values will be used..
  """
  def smart_max(left, right, opts) do
    smart_compare(left, right, opts)
    |> max()
  end

  @spec match_names(binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: float()
  @doc """
  Compare a string against a list of strings. Return a list of strings from the list which are a likely
  match for the first binary. A match has a maximum comparison score from at least one of the algorithms
  equal to or higher than the `match_cutoff`.

  `match_cutoff`, along with other options, are accepted as a list argument. If no options are given, the
  default values will be used for options. Also a keyword list of options.
  """
  def match_names(left, rights, opts \\ @opts)

  def match_names(left, rights, opts) when is_binary(left) and is_list(rights) do
    rights = Enum.map(rights, fn right -> compose(right) end)
    match_names(compose(left), rights, opts)
  end

  def match_names(%Corpus{} = left, rights, opts) do
    # Enum.reduce(rights, [], fn right, acc ->
    #   %{scores: scores} = NamesMetric.compare(left, right, opts)

    #   if Enum.any?(scores, fn {_algo, score} -> score > match_cutoff(opts) end) do
    #     [Enum.join(right.chunks, " ") | acc]
    #   else
    #     acc
    #   end
    # end)
    Enum.reduce(rights, [], fn %Corpus{} = right, acc ->
      if Enum.any?(Names.compare(left, right, opts), fn {_algo, score} ->
        score > match_cutoff(opts) end) do
        [Enum.join(right.chunks, " ") | acc]
      else
        acc
      end
    end)
  end

  @spec match_names_metrics(binary() | %Corpus{}, binary() | %Corpus{}, keyword()) :: float()
  @doc """
  Compare a string against a list of strings. Return a list of strings from the list which are a likely
  match for the first binary. A match has a maximum comparison score from at least one of the algorithms
  equal to or higher than the `match_cutoff`.

  `match_cutoff`, along with other options, are accepted as a list argument. If no options are given, the
  default values will be used for options. Also a keyword list of options.

  Return the matching names and their metrics.
  """
  def match_names_metrics(left, rights, opts \\ @opts)

  def match_names_metrics(left, rights, opts) when is_binary(left) and is_list(rights) do
    Enum.reduce(rights, [], fn right, acc ->
      case NamesMetric.compare(left, right, opts) do
        %{scores: scores} ->
          if Enum.any?(scores, fn {_algo, score} -> score > match_cutoff(opts) end) do
            [%{left: left, right: right, metrics: scores, match: 1}  | acc]
          else
            [%{left: left, right: right, metrics: scores, match: 0}  | acc]
          end
        _ -> acc
      end
    end)
  end

  @doc """
  Return the default option values
  """
  def default_opts, do: @opts

  @doc """
  Return a list of algorithms. Default returns all available algorithms. Accepts argument to limit
  the alorithms to a task.

  Accept a keyword list with two keys: short & has_whitespace.

  If short is true, one of the string
  is shorter than or equal to the `length cutoff`. There fore N-Gram alogrithms are excluded
  (Sorensen-Dice, Jaccard, NGram, Overlap, and Tversky)

  If has_whitespace is true, use algorithms best suited for comparing substrings (Sorensen-Dice,
  Jaccard, NGram, Overlap, and Tversky)
  """
  def algorithms([short: true, has_whitespace: true]) do
    ["chunk_set", "sorted_chunks", "double_metaphone._chunks"]
  end

  def algorithms([short: false, has_whitespace: true]) do
    ["chunk_set", "overlap", "sorted_chunks", "double_metaphone._chunks"]
  end

  def algorithms([short: true, has_whitespace: false]) do
    ["bag_distance", "sorensen_dice", "jaro_winkler", "levenshtein", "metaphone", "double_metaphone"]
  end

  def algorithms([short: false, has_whitespace: false]) do
    @algorithms -- ["hamming", "chunk_set", "sorted_chunks", "double_metaphone._chunks"]
  end

  def algorithms(), do: @algorithms

  @doc """
  Round data types that can be rounded to 2 decimal points.
  """
  def r(v) when is_float(v), do: Float.round(v, 2)
  def r(v) when is_binary(v), do: Float.round(String.to_float(v), 2)
  def r(v) when is_integer(v), do: Float.round(v / 1, 2)
end
