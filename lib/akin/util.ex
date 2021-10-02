defmodule Akin.Util do
  @moduledoc """
  Module for utilities to handle string preparation, manipulation, and inspection.
  """
  alias Akin.Corpus

  @doc """
  Compose a string into a corpus of values for disambiguation.
  Remove punctuation, downcase, trim excess whitespace. Return Corpus struct
  composed of Chunks, MapSet, String, and Stemmed Chunks.
  Non-binary terms result in return value nil

  ## Deaccentization

  Deaccentization handles names with accents, i.e. "Lundbye-Christensen, Søren". This name results in a binary when the regex replaces non-letter characters (<<76, 117, 110, 100, 98, 121, 101, 32, 67, 104, 114, 105, 115, 116, 101, 110,
  115, 101, 110, 32, 83, 195, 114, 101, 110>>). That must be converted to a list, and then a string. Running it through the regex replacement a second time polishes off any problematic conversions that occurred in those steps.
  """
  def compose(left, right) when is_binary(left) and is_binary(right) do
    [compose(left), compose(right)]
  end

  def compose(_, _), do: nil

  def compose(string) when is_binary(string) do
    chunks =
      string
      |> String.replace(["'", "-"], " ")
      |> deaccentize()
      |> String.downcase()
      |> String.split()
      |> Enum.map(&String.trim/1)

    %Corpus{
      set: MapSet.new(chunks),
      chunks: chunks,
      string: Enum.join(chunks),
      stems: Enum.map(chunks, &Stemmer.stem/1),
      original: ""
    }
  end

  def compose(_), do: nil

  defp deaccentize(name) when is_binary(name) do
    if String.contains?(name, " ") do
      Enum.map(String.split(name, " ", trim: true), fn nal ->
        deaccentize(nal)
      end)
      |> Enum.join(" ")
    else
      case :unicode.characters_to_nfd_binary(name) do
        {:error, letter, _b} ->
          letter
        l ->
          str = String.replace(l, ~r/\W/u, "")
          if String.valid?(str) do
            str
          else
            str
            |> :binary.bin_to_list()
            |> List.to_string()
            |> String.replace(~r/\W/u, "")
          end
      end
    end
  end

  @doc """
  Finds the length of a string in a less verbose way.
  """
  def len(value), do: String.length(value)

  @doc """
  Checks to see if a string is alphabetic.
  """
  def is_alphabetic?(value) when value in ["", nil], do: false
  def is_alphabetic?(value) do
    !Regex.match?(~r/[0-9]/, value)
    and (!Regex.match?(~r/\A[\p{L}\p{M}]+\z/, value) or !Regex.match?(~r/[\W0-9]/, value))
  end

  @doc """
  Removes duplicates from a string (except for c). Currently used in metaphone algorithm.
  """
  def deduplicate(value) when is_binary(value) do
    cond do
      String.length(value) <= 1 ->
        value

      true ->
        new_value =
          value
          |> String.codepoints()
          |> Stream.chunk_every(2, 1, :discard)
          |> Stream.filter(&(hd(&1) == "c" || hd(&1) != hd(tl(&1))))
          |> Stream.map(&hd(&1))
          |> Enum.to_list()
          |> to_string()

        new_value <> String.last(value)
    end
  end

  def deduplicate(value), do: value

  @doc """
  Finds the intersection of two lists.  If Strings are provided, it uses the
  codepoints of said string.
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
  Camelize input and return as an existing atom, as in referencing functions through apply
  """
  def modulize(list) when is_list(list), do: Enum.map(list, fn l -> modulize(l) end)

  def modulize(text) when is_binary(text) do
    String.to_atom("Elixir.Akin." <> Macro.camelize(text))
  end

  def modulize(text), do: text

  @doc """
  Tokenizes the input into N-grams (http://en.wikipedia.org/wiki/N-gram).
  """
  def ngram_tokenize(string, n) when is_binary(string) do
    ngram_tokenize(String.codepoints(string), n)
  end

  def ngram_tokenize(characters, n) do
    case n <= 0 || length(characters) < n do
      true ->
        nil

      false ->
        characters
        |> Stream.chunk_every(n, 1, :discard)
        |> Enum.map(&to_string(&1))
    end
  end

  def ngram_tokenize(_), do: []

  @spec ngram_size(keyword() | any()) :: integer()
  @doc """
  Take the n_gram size from the given options list. If not present, use the default value from the default
  options list.
  """
  # def ngram_size(opts) when Keyword.keyword?(opts) do
  #   Keyword.get(opts, :ngram_size) || Keyword.get(Akin.default_opts(), :ngram_size)
  # end
  def ngram_size([{:ngram_size, ngram_size}| _t]), do: ngram_size
  def ngram_size(_), do: Keyword.get(Akin.default_opts(), :ngram_size)

  @spec length_cutoff(keyword() | any()) :: integer()
  @doc """
  Take the ngram_size from the given options list. If not present, use the default value from the default
  options list.
  """
  def length_cutoff([{:length_cutoff, length_cutoff}| _t]), do: length_cutoff
  def length_cutoff(_), do: Keyword.get(Akin.default_opts(), :length_cutoff)

  @spec match_level(keyword() | any()) :: integer()
  @doc """
  Take the match_level from the given options list. If not present, use the default value from the default
  options list.
  """
  def match_level([{:match_level, match_level}| _t]), do: match_level
  def match_level(_), do: Keyword.get(Akin.default_opts(), :match_level)

  @spec match_cutoff(keyword() | any()) :: integer()
  @doc """
  Take the match_cutoff from the given options list. If not present, use the default value from the default
  options list.
  """
  def match_cutoff([{:match_cutoff, match_cutoff}| _t]), do: match_cutoff
  def match_cutoff(_), do: Keyword.get(Akin.default_opts(), :match_cutoff)

  @spec boost_initials?(keyword() | any()) :: boolean()
  @doc """
  Take the boost_initials from the given options list. If not present, return false.
  """
  def boost_initials?([{:boost_initials, boost_initials}| _t]) do
    if boost_initials, do: true, else: false
  end

  def boost_initials?(_), do: false

  @doc """
  Return a list of initial letter values (initials) from the `chunks` key in the Corpus struct.
  Used in name comparison, specifically.
  """
  def get_initials(%Corpus{chunks: chunks}) do
    Enum.map(chunks, fn chunk -> String.at(chunk, 0) end)
  end
  def get_initials(_), do: []
  # def initials(%Corpus{chunks: chunks}) do
  #   Enum.filter(chunks, fn chunk -> String.length(chunk) == 1 end)
  # end
  # def initials(_), do: []

  @doc """
  Compares to values for equality
  """
  def eq?(a, b) when a == b, do: true
  def eq?(_, _), do: false

  @doc """
  Flatten a list. Filter out nils. Filter out duplicates.
  """
  def flat_and_uniq(list) when is_list(list) do
    list
    |> List.flatten()
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.reject(fn x -> x == "" end)
    |> Enum.uniq()
  end

  def flat_and_uniq(list), do: list

  @spec replace_cond(binary(), binary() | list(), list()) :: tuple()
  @doc """
  If the conditions are met, replace character with white space. The right condition is when either but noth both the left or right strings contains the character.

  Accepts a left string and a right string or a right list of strings and list of characters to replace. Returns a tuple containing left and right with replacements, if replacements were made. Otherwise, the tuple contains the original strings.
  """
  def replace_cond(left, rights, char) when is_binary(left) and is_list(rights) do
    l? = String.contains?(left, char)
    Enum.map(rights, fn right -> replace_cond(left, right, char, l?) end)
  end

  def replace_cond(left, right, char) when is_binary(left) and is_binary(right) do
    l? = String.contains?(left, char)
    r? = String.contains?(right, char)
    replace_cond(left, right, char, l?, r?)
  end

  defp replace_cond(left, right, char, l?) do
    r? = String.contains?(right, char)
    replace_cond(left, right, char, l?, r?)
  end

  defp replace_cond(left, right, _char, l?, r?) when l? === r? do
    {left, right}
  end

  defp replace_cond(left, right, char, true, _) do
    new_left = String.replace(left, char, " ")
    {new_left, right}
  end

  defp replace_cond(left, right, char, _, true) do
    new_right = String.replace(right, char, " ")
    {left, new_right}
  end
end
