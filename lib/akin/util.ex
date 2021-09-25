defmodule Akin.Util do
  @moduledoc """
  Module for utilities to handle string preparation, manipulation, and inspection.
  """
  alias Akin.Primed

  @regex ~r/[\p{P}\p{S}]/

  @doc """
  Prime string for disambiguation. Remove punctuation, downcase, trim
  excess whitespace. Return Primed struct.
  """
  def prime(left, right) when is_binary(left) and is_binary(right) do
    {prime(left), prime(right)}
  end

  def prime(string) when is_binary(string) do
    chunks =
      string
      |> String.replace(@regex, " ")
      |> String.downcase()
      |> String.split()
      |> Enum.map(&String.trim/1)

    %Primed{
      set: MapSet.new(chunks),
      chunks: chunks,
      string: Enum.join(chunks),
      stems: Enum.map(chunks, &Stemmer.stem/1)
    }
  end

  def prepared(_), do: ""

  def deaccentize(name) do
    if String.contains?(name, " ") do
      name_as_list = String.split(name, " ", trim: true)

      Enum.map(name_as_list, fn nal ->
        deaccentize(nal)
      end)
      |> Enum.join(" ")
    else
      :unicode.characters_to_nfd_binary(name)
      |> String.replace(~r/\W/u, "")
    end
  end

  @doc """
  Flatten a list, filter out nil values and empty strings, and return (same as above, but with uniq/1
  """
  def flatten(list) do
    list
    |> List.flatten()
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.reject(fn x -> x == "" end)
  end

  @doc """
  Finds the length of a string in a less verbose way.
  """
  def len(value), do: String.length(value)

  @doc """
  Checks to see if a string is alphabetic.

  Akin.Util.is_alphabetic?("Jason5")
  Returns false

  Akin.Util.is_alphabetic?("Jason")
  Returns true
  """
  def is_alphabetic?(value) do
    !Regex.match?(~r/[\W0-9]/, value)
  end

  @doc """
  Removes duplicates from a string (except for c)
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

  Akin.Util.intersect("context", "contentcontent")
  Returns ["c", "o", "n", "t", "e", "t"]
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

  Akin.Util.ngram_tokenize("abcdefghijklmnopqrstuvwxyz", 2)
  Returns ["ab", "bc", "cd", "de", "ef", "fg", "gh", "hi", "ij", "jk", "kl", "lm",
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
  def modulize(text) when is_binary(text) do
    String.to_atom("Elixir.Akin." <> Macro.camelize(text))
  end
  def modulize(text), do: text

  @spec name_parts(String.t() | nil, String.t() | nil, String.t() | nil) :: map()
  @doc """
  Convert first, middle, and last names into a map of elements. Duplicates are removed so that if a name combination
  is used for one part, it is not used again for any subsequent name part. The assignment order is:

  1.  fml:    "Jane Anne Doe" (first name, middle name, last name)
  2.  f:      "Jane"          (first name)
  3.  m:      "Anne"          (middle name)
  4.  l:      "Doe"           (last name)
  5.  fi:     "J"             (initial of first name)
  6.  mi:     "A"             (initial of middle name)
  7.  li:     "D"             (initial of last name)
  8.  fmil:   "Jane A Doe"    (first name, initial of middle name, last name)
  9.  fimil:  "J A Doe"       (initial of first name, initial of middle name, last name)
  10. fl:     "Jane Doe"      (first name, last name)
  11. fil:    "J Doe"         (initial of first name, last name)
  12. fli:    "Jane D"        (first name, initial of last name)
  13. fm:     "Jane Anne"     (first name, initial of last name)
  14. fimili: "J A D"         (initial of first name, initial of middle name, initial of last name)
  15. fili:   "J D"           (initial of first name, initial of last name)
  16. fimi:   "J A"           (initial of first name, initial of middle name)

  If the name has first, middle, last ("Jane", "Anne", "Doe") the map is

  ``` elixir
  %{
    f: "jane",
    fi: "j",
    fil: "j doe",
    fili: "j d",
    fimi: "j a",
    fimil: "j a doe",
    fimili: "j a d",
    fl: "jane doe",
    fli: "jane d",
    fm: "jane anne",
    fmil: "jane a doe",
    fml: "jane anne doe",
    l: "doe",
    li: "d",
    m: "anne",
    mi: "a"
  }
  ```

  If the name is first, last ("Jane", "", "Doe") the map is

  ``` elixir
  %{
    f: "jane",
    fi: "j",
    fil: "",
    fili: "j d",
    fimi: "",
    fimil: "j doe",
    fimili: "",
    fl: "",
    fli: "jane d",
    fm: "",
    fmil: "",
    fml: "jane doe",
    l: "doe",
    li: "d",
    m: "",
    mi: ""
  }
  ```

  If the name is first, last ("Jane", "Anne") the map is

  ``` elixir
  %{
    f: "jane",
    fi: "j",
    fil: "",
    fili: "",
    fimi: "",
    fimil: "j a",
    fimili: "",
    fl: "",
    fli: "",
    fm: "",
    fmil: "jane a",
    fml: "jane anne",
    l: "",
    li: "",
    m: "anne",
    mi: "a"
  }
  ```

  If the name is first, last ("Jane", "A", "Doe") the map is

  ``` elixir
  %{
    f: "jane",
    fi: "j",
    fil: "j doe",
    fili: "j d",
    fimi: "j a",
    fimil: "j a doe",
    fimili: "j a d",
    fl: "jane doe",
    fli: "jane d",
    fm: "jane a",
    fmil: "",
    fml: "jane a doe",
    l: "doe",
    li: "d",
    m: "a",
    mi: "a"
  }
  ```
  """
  def name_parts(%{first: first, middle: middle, last: last}), do: name_parts(first, middle, last)
  def name_parts(first_name, middle_name, last_name) do
    [f, fi] = parse_name(first_name)
    [m, mi] = parse_name(middle_name)
    [l, li] = parse_name(last_name)

    fml = combine(f, m, l)

    {fmil, used} = dry_name(combine(f, mi, l), [f, m, l, fi, mi, li, fml])
    {fimil, used} = dry_name(combine(fi, mi, l), used)
    {fl, used} = dry_name(combine(f, nil, l), used)
    {fil, used} = dry_name(combine(fi, nil, l), used)

    {fli, used} = dry_name(combine(f, nil, li), used)
    {fm, used} = dry_name(combine(f, m, nil), used)
    {fili, used} = dry_name(combine(fi, nil, li), used)
    {fimi, used} = dry_name(combine(fi, mi, nil), used)
    {fim, used} = dry_name(combine(fi, m, nil), used)
    {fimili, _used} = dry_name(combine(fi, mi, li), used)

    %{
      f: f, m: m, l: l, fi: fi, mi: mi, li: li,
      fml: fml, fmil: fmil, fimil: fimil, fl: fl, fil: fil,
      fli: fli, fm: fm, fili: fili, fimi: fimi, fim: fim, fimili: fimili
    }
  end

  @spec dry_name(String.t(), list(String.t())) :: tuple()
  @doc """
  Do not repeat names. If the given name is in the list of already used names, return an empty string.

  Akin.Util.dry_name("jane a doe", [])
  Returns {"jane a doe", ["jane a doe"]}

  Akin.Util.dry_name("jane a doe", ["jane", "a", "doe", "j", "a", "d", "jane a doe"])
  Returns {"", ["jane", "a", "doe", "j", "a", "d", "jane a doe"]}
  """
  def dry_name(name, used) when is_binary(name) and is_list(used) do
    if name in used do
      {"", used}
    else
      {name, [used, [name]] |> List.flatten()}
    end
  end
  def dry_name(_, used), do: {"", used}

  @spec get_initial(String.t() | nil) :: String.t()
  @doc """
  Get the initial letter of a name (string). Return it downcased.

    - "Jane" returns "J"
    - nil returns ""

  Akin.Util.get_initial("jane")
  Returns "j"
  """
  def get_initial(name) when is_binary(name) do
    String.slice(name, 0..0)
  end
  def get_initial(nil), do: ""

  @spec parse_name(String.t() | nil) :: list(any())
  @doc """
  Normalizes and then parses a name (string) into a list containing the downcased & trimmed name plus the initial letter of the name.

    - "Jane" returns ["Jane", "J"]
    - nil returns ["", ""]

  Akin.Util.parse_name("jane")
  Returns ["jane", "j"]
  """
  def parse_name(name) when is_binary(name) do
    [name, name |> get_initial()]
  end
  def parse_name(nil), do: ["", ""]

  @spec combine(String.t() | nil, String.t() | nil, String.t() | nil) :: String.t()
  @doc """
  Name (string) values are put into a list. The list is interspersed with a blank space between elements. Nil values are filtered out of
  the list. The list is transformed to a string and white space is trimmed.

    - "Jane", "Anne", "Doe" returns "Jane Anne Doe"
    - "Jane", " ", "Doe" returns "Jane Doe"
    - "Jane", nil, "Doe" returns "Jane Doe"
    - "Jane", "Doe" returns "Jane Doe"
    - nil returns []
  """
  def combine(one \\ nil, two \\ nil, three \\ nil)
  def combine(nil, nil, nil), do: ""
  def combine(one, two, three) do
    [one, two, three]
    |> Enum.intersperse(" ")
    |> Enum.filter(&(!is_nil(&1)))
    |> List.to_string()
  end

  def split(nil) do
    %{
      first: "",
      middle: "",
      last: "",
      full: ""
    }
  end

  def split(name), do: split(name, String.contains?(name, ","))

  def split(name, true) do
    # the name contains a comma, like "kurt Kroenke, md" or "sammie davis, jr"
    name = String.replace(name, ",", ", ") |> String.replace("  ", " ")
    case String.split(name, ", ") do
      [n, postcomma] ->
        split_name = split(n)
        l = split_name.last  <> ", " <> postcomma
        f = split_name.first
        m = split_name.middle
        %{
          first: f,
          middle: m,
          last: l,
          full: Enum.join([f, m, l], " ")
        }
      [n] -> String.replace(n, ",", " ") |> String.trim()
      _ -> name
    end
  end
  def split(name, false) do
    name
    |> String.split()
    |> case do
      [f, m, l] ->
        %{
          first: f,
          middle: m,
          last: l,
          full: Enum.join([f, m, l], " ")
        }
      [f, l] ->
        %{
          first: f,
          middle: "",
          last: l,
          full: Enum.join([f, l], " ")
        }
      [f] -> %{
          first: f,
          middle: "",
          last: "",
          full: ""
        }
      [f | tail] ->
        l = List.last(tail)
        m = tail -- [l] |> Enum.join(" ")
        %{
          first: f,
          middle: m,
          last: l,
          full: Enum.join([f, m, l], " ")
        }
      _ -> %{
        first: "",
        middle: "",
        last: "",
        full: ""
      }
    end
  end
end
