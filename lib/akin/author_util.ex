defmodule Akin.AuthorUtil do
  @moduledoc """
  Module for utilities to handle specifically author names.
  """

  @common_suffixes ["jr", "esq", "ret", "sr", "ii", "iii", "iv", "v", "vi", "cpa", "dc", "vm", "dds", "jd", "md", "phd"]

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

  ## Examples

      iex> Akin.AuthorUtil.dry_name("jane a doe", [])
      {"jane a doe", ["jane a doe"]}
      iex> Akin.AuthorUtil.dry_name("jane a doe", ["jane", "a", "doe", "j", "a", "d", "jane a doe"])
      {"", ["jane", "a", "doe", "j", "a", "d", "jane a doe"]}
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

  ## Examples

    iex> Akin.AuthorUtil.get_initial("jane")
    "j"
    iex> Akin.AuthorUtil.get_initial("Doe")
    "d"
    iex> Akin.AuthorUtil.get_initial("")
    ""
  """
  def get_initial(name) when is_binary(name) do
    String.slice(name, 0..0) |> trim_downcase()
  end
  def get_initial(nil), do: ""

  @spec parse_name(String.t() | nil) :: list(any())
  @doc """
  Normalizes and then parses a name (string) into a list containing the downcased & trimmed name plus the initial letter of the name.

    - "Jane" returns ["Jane", "J"]
    - nil returns ["", ""]

  ## Examples

    iex> Akin.AuthorUtil.parse_name("jane")
    ["jane", "j"]
    iex> Akin.AuthorUtil.parse_name("Doe")
    ["doe", "d"]
    iex> Akin.AuthorUtil.parse_name("")
    ["", ""]
  """
  def parse_name(name) when is_binary(name) do
    name = normalize(name)
    [name |> trim_downcase(), name |> get_initial()]
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

  ## Examples

    iex> Akin.AuthorUtil.combine("Jane", "Anne", "Doe")
    "jane anne doe"
    iex> Akin.AuthorUtil.combine("Jane", " ", "Doe")
    "jane doe"
    iex> Akin.AuthorUtil.combine("Jane", nil, "Doe")
    "jane doe"
    iex> Akin.AuthorUtil.combine("Jane", "Anne")
    "jane anne"
  """
  def combine(one \\ nil, two \\ nil, three \\ nil)
  def combine(nil, nil, nil), do: ""
  def combine(one, two, three) do
    [one, two, three]
    |> Enum.intersperse(" ")
    |> Enum.filter(&(!is_nil(&1)))
    |> List.to_string()
    |> trim_downcase()
  end

  @spec normalize(String.t() | nil) :: String.t()
  @doc """
  Name (string) values are normalized by replacing '.' with whitespace, trimming
  downcasing, removal of symbols. This function does not deaccentize. That step
  is separate through the function deaccentize/1.

    - "b.w." returns "b w"
    - "jane b. doe" returns "jane b doe"
    - nil returns ""

  ## Examples

    iex> Akin.AuthorUtil.normalize("b.w.")
    "b w"
    iex> Akin.AuthorUtil.normalize("jane b. doe")
    "jane b doe"
    iex> Akin.AuthorUtil.normalize(nil)
    ""
  """
  def normalize(nil), do: ""
  def normalize(name) do
    name
    |> downcase()
    |> String.replace(".", " ")
    |> remove_symbols()
    |> String.trim()
    |> String.replace("  ", " ")
  end

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

  def split(nil) do
    %{
      first: "",
      middle: "",
      last: "",
      full: ""
    }
  end
  def split(name) do
    normalized_name = normalize(name)
    split(normalized_name, String.contains?(normalized_name, ","))
  end
  def split(name, true) do
    # the name contains a comma, like "kurt Kroenke, md" or "sammie davis, jr"
    name = String.replace(name, ",", ", ") |> String.replace("  ", " ")
    case String.split(name, ", ") do
      [n, postcomma] ->
        [n, postcomma] = flip_split([n, postcomma])
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

  @doc """
  If a common suffix appears first in the split name, flip them.
  """
  def flip_split([n, postcomma]) do
    n = String.trim(n)
    if n in @common_suffixes, do: [postcomma, n], else: [n, postcomma]
  end

  @doc """
  Enhance the search spec by the name permutations.

  - if the given or family name includes a hypen (-), add an alias of the name without the hyphen
  - if the given, middle, or family name include unicode, create an alias of a version with unicode translated
  """
  def enhance_spec_by_permutations(search_spec, permutations) do
    hyphenless = if String.contains?(permutations.l, "-") or String.contains?(permutations.f, "-") do
        given = String.replace(permutations.f, "-", " ") |> normalize()
        family = String.replace(permutations.l, "-", " ") |> normalize()
        Enum.join([given, permutations.m, family], " ")
          |> String.replace("  ", " ")
          |> String.trim()
      else
        []
      end

    accentless = if :unicode.characters_to_nfd_binary(permutations.l) == permutations.l &&
      :unicode.characters_to_nfd_binary(permutations.f) == permutations.f do
        []
      else
        Enum.join([permutations.f, permutations.m, permutations.l], " ")
        |> String.replace("  ", " ")
        |> String.trim()
      end

    %{search_spec | aliases: [search_spec.aliases | [hyphenless | [accentless]]] |> flatten()}
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
  Downcase strings.
  """
  def downcase(text) when is_binary(text), do: String.downcase(text)
  def downcase(list) when is_list(list) do
    Enum.map(list, fn text -> downcase(text) end)
  end
  def downcase(text), do: text

  @doc """
  Remove symbols from a string or from every string in a list. Symbols removed are:

  ["|", "&", "*", "(", ")", ".", ":", "\\n", "\\", "!", "?"]
  """
  def remove_symbols(list) when is_list(list) do
    Enum.map(list, fn text ->
      remove_symbols(text)
    end)
  end
  def remove_symbols(text) do
    try do
      String.replace(text, ["|", "&", "*", "(", ")", ".", ":", "\\n", "\\t", "\\r", "\\", "!", "?"], fn _ -> "" end)
    rescue _e ->
      text
    end
  end

  @doc """
  Trim white space off beginning and end of each string in a list and turn all letters to lower case.
  Or trim white space off beginning and end of a string and turn all letters to lower case.
  """
  def trim_downcase(list) when is_list(list) do
    Enum.map(list, fn l -> trim_downcase(l)
    |> String.replace(~r/\s+/, " ")  end)
  end
  def trim_downcase(nil), do: ""
  def trim_downcase(""), do: ""
  def trim_downcase(value) do
    value
    |> String.downcase()
    |> String.trim()
    |> String.replace(~r/\s+/, " ")
  end
end
