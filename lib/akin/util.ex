defmodule Akin.Util do
  @moduledoc """
  Utilities for Akin.
  """

  @doc """
  Finds the length of a string in a less verbose way.
  ## Example
      iex> Akin.Util.len("Jason")
      5
  """
  def len(value), do: String.length(value)

  @doc """
  Checks to see if a string is alphabetic.
  ## Example
      iex> Akin.Util.is_alphabetic?("Jason5")
      false
      iex> Akin.Util.is_alphabetic?("Jason")
      true
  """
  def is_alphabetic?(value) do
    !Regex.match?(~r/[\W0-9]/, value)
  end

  @doc """
  Removes duplicates from a string (except for c)
  ## Example
      iex> Akin.Util.deduplicate("buzz")
      "buz"
      iex> Akin.Util.deduplicate("accept")
      "accept"
  """
  def deduplicate(value) do
    cond do
      String.length(value) <= 1 ->
        value

      true ->
        new_value = value
          |> String.codepoints()
          |> Stream.chunk_every(2, 1, :discard)
          |> Stream.filter(&(hd(&1) == "c" || hd(&1) != hd(tl(&1))))
          |> Stream.map(&hd(&1))
          |> Enum.to_list()
          |> to_string()
        new_value <> String.last(value)
    end
  end

  @doc """
  Finds the intersection of two lists.  If Strings are provided, it uses the
  codepoints of said string.
  ## Example
      iex> Akin.Util.intersect('context', 'contentcontent')
      'contet'
      iex> Akin.Util.intersect("context", "contentcontent")
      ["c", "o", "n", "t", "e", "t"]
  """
  def intersect(left, right) when is_binary(left) and is_binary(right) do
    intersect(String.codepoints(left), String.codepoints(right))
  end

  def intersect(left, right), do: intersect(left, right, length(left), length(right), [])
  defp intersect(_, _, s1, s2, acc) when s1 == 0 or s2 == 0, do: acc

  defp intersect(left, right, s1, s2, acc) do
    cond do
      hd(left) == hd(right) ->
        intersect(tl(left), tl(right), s1 - 1, s2 - 1, acc ++ [hd(right)])

      Enum.find_index(left, &(&1 == hd(right))) == nil ->
        intersect(left, tl(right), s1, s2 - 1, acc)

      true ->
        cond do
          max(s1, s2) == s1 ->
            intersect(tl(left), right, s1 - 1, s2, acc)

          true ->
            intersect(left, tl(right), s1, s2 - 1, acc)
        end
    end
  end

  @doc """
  [ngram tokenizes](http://en.wikipedia.org/wiki/N-gram) the string provided.
  ## Example
      iex> Akin.Util.ngram_tokenize("abcdefghijklmnopqrstuvwxyz", 2)
      ["ab", "bc", "cd", "de", "ef", "fg", "gh", "hi", "ij", "jk", "kl", "lm",
      "mn", "no", "op", "pq", "qr", "rs", "st", "tu", "uv", "vw", "wx", "xy",
      "yz"]
  """
  def ngram_tokenize(string, n) when is_binary(string) do
    ngram_tokenize(String.codepoints(string), n)
  end

  def ngram_tokenize(characters, n) do
    case n <= 0 || length(characters) < n do
      true -> nil
      false ->
        characters
        |> Stream.chunk_every(n, 1, :discard)
        |> Enum.map(&to_string(&1))
    end
  end

  @doc """
  Camelize input and return as an existing atom, as in referencing functions through apply
  """
  def modulize(list) when is_list(list), do: Enum.map(list, fn l -> modulize(l) end)
  def modulize(atom) when is_atom(atom), do: modulize(Atom.to_string(atom))
  def modulize(text) when is_binary(text) do
    String.to_existing_atom("Elixir.Akin.Similarity." <> Macro.camelize(text))
  end
  def modulize(text), do: text
end
