defmodule Akin.Metaphone.Double do
  @moduledoc """
  The original Metaphone algorithm was published in 1990 as an improvement over
  the Soundex algorithm. Like Soundex, it was limited to English-only use. The
  Metaphone algorithm does not produce phonetic representations of an input word
  or name; rather, the output is an intentionally approximate phonetic
  representation. The approximate encoding is necessary to account for the way
  speakers vary their pronunciations and misspell or otherwise vary words and
  names they are trying to spell.

  The Double Metaphone phonetic encoding algorithm is the second generation of
  the Metaphone algorithm. Its implementation was described in the June 2000
  issue of C/C++ Users Journal. It makes a number of fundamental design
  improvements over the original Metaphone algorithm.

  It is called "Double" because it can return both a primary and a secondary code
  for a string; this accounts for some ambiguous cases as well as for multiple
  variants of surnames with common ancestry. For example, encoding the name
  "Smith" yields a primary code of SM0 and a secondary code of XMT, while the
  name "Schmidt" yields a primary code of XMT and a secondary code of SMT--both
  have XMT in common.

  Double Metaphone tries to account for myriad irregularities in English of
  Slavic, Germanic, Celtic, Greek, French, Italian, Spanish, Chinese, and other
  origin. Thus it uses a much more complex ruleset for coding than its
  predecessor; for example, it tests for approximately 100 different contexts of
  the use of the letter C alone.

  This script implements the Double Metaphone algorithm (c) 1998, 1999 originally
  implemented by Lawrence Philips in C++. It was further modified in C++ by Kevin
  Atkinson (http://aspell.net/metaphone/). It was translated to C by Maurice
  Aubrey <maurice@hevanet.com> for use in a Perl extension. A Python version was
  created by Andrew Collins on January 12, 2007, using the C source
  (http://www.atomodo.com/code/double-metaphone/metaphone.py/view). This version is
  based on the python version.

  The next key in the struct is used set to a tuple of the next characters in the
  primary and secondary codes and to indicate how many characters to move forward
  in the string.  The secondary code letter is given only when it is different than
  the primary. This is an effort to make the code easier to write and read. The
  default action is to add nothing and move to next char.
  """
  defstruct(position: 0, primary_phone: "", secondary_phone: "", next: {nil, 1}, word: nil)
  alias Word
  alias Akin.Metaphone.Double

  @vowels ["A", "E", "I", "O", "U", "Y"]
  @silent_starters ["GN", "KN", "PN", "WR", "PS"]

  @doc """
  Initialize the struct
  """
  def init(input) do
    %Double{word: Word.init(input)}
  end

  @doc """
  Iterate input characters
  """
  def parse(input) when is_binary(input) do
    metaphone = init(input) |> check_word_start()
    position = metaphone.position
    end_index = metaphone.word.end_index
    character = letter_at_position(metaphone, position)

    parse(metaphone, position, end_index, character)
  end

  def parse(_), do: {"", ""}

  def parse(
        %Double{primary_phone: primary, secondary_phone: secondary},
        position,
        end_index,
        _character
      )
      when position > end_index and
             secondary in [nil, "", " "] do
    return_phones({primary, ""})
  end

  def parse(
        %Double{primary_phone: primary, secondary_phone: secondary},
        position,
        end_index,
        _character
      )
      when position > end_index do
    return_phones({primary, secondary})
  end

  def parse(%Double{} = metaphone, position, end_index, character)
      when character == " " do
    position = position + 1
    metaphone = %{metaphone | position: position}
    character = letter_at_position(metaphone, position)
    parse(metaphone, position, end_index, character)
  end

  def parse(%Double{} = metaphone, position, _end_index, character) do
    initial_process(metaphone, position, character)
    |> build_phones()
    |> parse_next()
  end

  @doc """
  Compare two strings, returning the outcome of the comparison using the
  strictness of the level.

  - "strict": both encodings for each string must match
  - "strong": the primary encoding for each string must match
  - "normal": the primary encoding of one string must match either encoding of other string (default)
  - "weak":   either primary or secondary encoding of one string must match one encoding of other string
  """
  def compare(left, right, level \\ "normal")

  def compare(left, right, level) when is_binary(left) and is_binary(right) do
    compare(parse(left), parse(right), level)
  end

  def compare({"", ""}, {"", ""}, _), do: false

  def compare({primary_left, secondary_left}, {primary_right, secondary_right}, "strict")
      when primary_left == primary_right and
             secondary_left == secondary_right do
    true
  end

  def compare(_, _, "strict"), do: false

  def compare({left, _}, {right, _}, "strong") when left == right, do: true
  def compare(_, _, "strong"), do: false

  def compare({primary_left, secondary_left}, {primary_right, secondary_right}, "weak")
      when primary_left in [primary_right, secondary_right] or
             secondary_left in [primary_right, secondary_right] do
    true
  end

  def compare(_, _, "weak"), do: false

  def compare({primary_left, secondary_left}, {primary_right, secondary_right}, "normal")
      when primary_left in [primary_right, secondary_right] or
             primary_right in [primary_left, secondary_left] do
    true
  end

  def compare(_, _, "normal"), do: false

  @doc """
  Skip silent letters at the start of a word or replace the X if the word starts with
  X as in Xavier with an S
  """
  def check_word_start(%Double{position: position} = metaphone) do
    if letter_at_position(metaphone, metaphone.word.start_index, metaphone.word.start_index + 2) in @silent_starters do
      %{metaphone | position: position + 3}
    else
      if letter_at_position(metaphone, metaphone.word.start_index) == "X" do
        if String.length(metaphone.word.original) == 1 do
          %{metaphone | position: position + 3, primary_phone: "S", secondary_phone: "S"}
        else
          %{metaphone | position: position + 2, primary_phone: "S", secondary_phone: "S"}
        end
      else
        metaphone
      end
    end
  end

  @doc """
  All initial vowels map to "A"
  """
  def process_initial_vowels(%Double{} = metaphone, position) do
    if position == metaphone.word.start_index do
      %{metaphone | next: {"A", 1}}
    else
      %{metaphone | next: {nil, 1}}
    end
  end

  @doc """
  Handle conditional cases for different letters. Update phoenemes in the `next` param
  of the metaphone struct and return the struct.

  """
  def process(%Double{position: position} = metaphone, character) when character == "B" do
    if letter_at_position(metaphone, position + 1) == "B" do
      %{metaphone | next: {"P", 2}}
    else
      %{metaphone | next: {"P", 1}}
    end
  end

  def process(
        %Double{position: position, word: %Word{start_index: start_index}} = metaphone,
        character
      )
      when character == "C" do
    if position > start_index + 1 and
         letter_at_position(metaphone, position - 2) not in @vowels and
         letter_at_position(metaphone, position - 1, position + 2) == "ACH" and
         letter_at_position(metaphone, position + 2) not in ["I"] and
         (letter_at_position(metaphone, position + 2) not in ["E"] or
            letter_at_position(metaphone, position - 2, position + 4) in [
              "BACHER",
              "MACHER"
            ]) do
      %{metaphone | next: {"K", 2}}
    else
      if position == start_index and
           letter_at_position(metaphone, start_index, start_index + 6) == "CAESAR" do
        %{metaphone | next: {"S", 2}}
      else
        if letter_at_position(metaphone, position, position + 4) == "CHIA" do
          %{metaphone | next: {"K", 2}}
        else
          if letter_at_position(metaphone, position, position + 2) == "CH" do
            if position > start_index and
                 letter_at_position(metaphone, position, position + 4) == "CHAE" do
              %{metaphone | next: {"K", "X", 2}}
            else
              if ((position == start_index and
                     letter_at_position(metaphone, position + 1, position + 6) in [
                       "HARAC",
                       "HARIS"
                     ]) or
                    letter_at_position(metaphone, position + 1, position + 4) in [
                      "HOR",
                      "HYM",
                      "HIA",
                      "HEM"
                    ]) and
                   letter_at_position(metaphone, start_index, start_index + 5) != "CHORE" do
                %{metaphone | next: {"K", 2}}
              else
                if letter_at_position(metaphone, start_index, start_index + 4) in ["VAN", "VON"] or
                     letter_at_position(metaphone, start_index, start_index + 3) == "SCH" or
                     letter_at_position(metaphone, position - 2, position + 4) in [
                       "ORCHES",
                       "ARCHIT",
                       "ORCHID"
                     ] or
                     letter_at_position(metaphone, position + 2) in ["T", "S"] or
                     ((letter_at_position(metaphone, position - 1) in ["A", "O", "U", "E"] or
                         position == start_index) and
                        letter_at_position(metaphone, position + 2) in [
                          "L",
                          "R",
                          "N",
                          "M",
                          "B",
                          "H",
                          "F",
                          "V",
                          "W",
                          " "
                        ]) do
                  %{metaphone | next: {"K", 2}}
                else
                  if position > start_index do
                    if letter_at_position(metaphone, start_index, start_index + 2) == "MC" do
                      %{metaphone | next: {"K", 2}}
                    else
                      %{metaphone | next: {"X", "K", 2}}
                    end
                  else
                    %{metaphone | next: {"X", 2}}
                  end
                end
              end
            end
          else
            if letter_at_position(metaphone, position, position + 2) == "CZ" and
                 letter_at_position(metaphone, position - 2, position + 2) != "WICZ" do
              %{metaphone | next: {"S", "X", 2}}
            else
              if letter_at_position(metaphone, position + 1, position + 4) == "CIA" do
                %{metaphone | next: {"X", 3}}
              else
                if letter_at_position(metaphone, position, position + 2) == "CC" and
                     not (position == start_index + 1 and
                            letter_at_position(metaphone, start_index) == "M") do
                  if letter_at_position(metaphone, position + 2) in ["I", "E", "H"] and
                       letter_at_position(metaphone, position + 2, position + 4) != "HU" do
                    if (position == start_index + 1 and
                          letter_at_position(metaphone, start_index) == "A") or
                         letter_at_position(metaphone, position - 1, position + 4) in [
                           "UCCEE",
                           "UCCES"
                         ] do
                      %{metaphone | next: {"KS", 3}}
                    else
                      %{metaphone | next: {"X", 3}}
                    end
                  else
                    %{metaphone | next: {"K", 2}}
                  end
                else
                  if letter_at_position(metaphone, position, position + 2) in ["CK", "CG", "CQ"] do
                    %{metaphone | next: {"K", 3}}
                  else
                    if letter_at_position(metaphone, position, position + 2) in ["CI", "CE", "CY"] do
                      if letter_at_position(metaphone, position, position + 3) in [
                           "CIO",
                           "CIE",
                           "CIA"
                         ] do
                        %{metaphone | next: {"S", "X", 2}}
                      else
                        %{metaphone | next: {"S", 2}}
                      end
                    else
                      if letter_at_position(metaphone, position + 1, position + 3) in [
                           " C",
                           " Q",
                           " G"
                         ] do
                        %{metaphone | next: {"K", 3}}
                      else
                        if letter_at_position(metaphone, position + 1) in ["C", "K", "Q"] and
                             letter_at_position(metaphone, position + 1, position + 3) not in [
                               "CE",
                               "CI"
                             ] do
                          %{metaphone | next: {"K", 2}}
                        else
                          %{metaphone | next: {"K", 1}}
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def process(%Double{position: position} = metaphone, character) when character == "D" do
    if letter_at_position(metaphone, position, position + 2) == "DG" do
      if letter_at_position(metaphone, position + 2) in ["I", "E", "Y"] do
        %{metaphone | next: {"J", 3}}
      else
        %{metaphone | next: {"TK", 2}}
      end
    else
      if letter_at_position(metaphone, position, position + 2) in ["DT", "DD"] do
        %{metaphone | next: {"T", 2}}
      else
        %{metaphone | next: {"T", 1}}
      end
    end
  end

  def process(%Double{position: position} = metaphone, character) when character == "F" do
    if letter_at_position(metaphone, position + 1) == "F" do
      %{metaphone | next: {"F", 2}}
    else
      %{metaphone | next: {"F", 1}}
    end
  end

  def process(
        %Double{position: position, word: %Word{start_index: start_index}} = metaphone,
        character
      )
      when character == "G" do
    if letter_at_position(metaphone, position + 1) == "H" do
      if position > start_index and
           letter_at_position(metaphone, position - 1) not in @vowels do
        %{metaphone | next: {"K", 2}}
      else
        if position < start_index + 3 do
          if position == start_index do
            if letter_at_position(metaphone, position + 2) == "I" do
              %{metaphone | next: {"J", 2}}
            else
              %{metaphone | next: {"K", 2}}
            end
          else
            %{metaphone | next: {nil, 2}}
          end
        else
          if (position > start_index + 1 and
                letter_at_position(metaphone, position - 2) in ["B", "H", "D"]) or
               (position > start_index + 2 and
                  letter_at_position(metaphone, position - 3) in ["B", "H", "D"]) or
               (position > start_index + 3 and
                  letter_at_position(metaphone, position - 4) in ["B", "H"]) do
            %{metaphone | next: {nil, 2}}
          else
            if position > start_index + 2 and
                 letter_at_position(metaphone, position - 1) == "U" and
                 letter_at_position(metaphone, position - 3) in ["C", "G", "L", "R", "T"] do
              %{metaphone | next: {"F", 2}}
            else
              if position > start_index and
                   letter_at_position(metaphone, position - 1) != "I" do
                %{metaphone | next: {"K", 2}}
              else
                %{metaphone | next: {nil, 2}}
              end
            end
          end
        end
      end
    else
      if letter_at_position(metaphone, position + 1) == "N" do
        if position == start_index + 1 and
             letter_at_position(metaphone, start_index) in @vowels and
             not Word.is_slavo_germanic?(metaphone.word) do
          %{metaphone | next: {"KN", "N", 2}}
        else
          if letter_at_position(metaphone, position + 2, position + 4) != "EY" and
               letter_at_position(metaphone, position + 1) != "Y" and
               not Word.is_slavo_germanic?(metaphone.word) do
            %{metaphone | next: {"N", "KN", 2}}
          else
            %{metaphone | next: {"KN", 2}}
          end
        end
      else
        if letter_at_position(metaphone, position + 1, position + 3) == "LI" and
             not Word.is_slavo_germanic?(metaphone.word) do
          %{metaphone | next: {"KL", "L", 2}}
        else
          if position == start_index and
               (letter_at_position(metaphone, position + 1) == "Y" or
                  letter_at_position(metaphone, position + 1, position + 3) in [
                    "ES",
                    "EP",
                    "EB",
                    "EL",
                    "EY",
                    "IB",
                    "IL",
                    "IN",
                    "IE",
                    "EI",
                    "ER"
                  ]) do
            %{metaphone | next: {"K", "J", 2}}
          else
            if (letter_at_position(metaphone, position + 1, position + 3) == "ER" or
                  letter_at_position(metaphone, position + 1) == "Y") and
                 letter_at_position(metaphone, start_index, start_index + 6) not in [
                   "DANGER",
                   "RANGER",
                   "MANGER"
                 ] and
                 letter_at_position(metaphone, position - 1) not in ["E", "I"] and
                 letter_at_position(metaphone, position - 1, position + 2) not in ["RGY", "OGY"] do
              %{metaphone | next: {"K", "J", 2}}
            else
              if letter_at_position(metaphone, position + 1) in ["E", "I", "Y"] or
                   letter_at_position(metaphone, position - 1, position + 3) in ["AGGI", "OGGI"] do
                if letter_at_position(metaphone, start_index, start_index + 4) in ["VON", "VAN"] or
                     letter_at_position(metaphone, start_index, start_index + 3) == "SCH" or
                     letter_at_position(metaphone, position + 1, position + 3) == "ET" do
                  %{metaphone | next: {"K", 2}}
                else
                  if letter_at_position(metaphone, position + 1, position + 5) == "IER" do
                    %{metaphone | next: {"J", 2}}
                  else
                    %{metaphone | next: {"J", "K", 2}}
                  end
                end
              else
                if letter_at_position(metaphone, position + 1) == "G" do
                  %{metaphone | next: {"K", 2}}
                else
                  %{metaphone | next: {"K", 1}}
                end
              end
            end
          end
        end
      end
    end
  end

  def process(%Double{position: position} = metaphone, character) when character == "H" do
    if position == metaphone.word.start_index or
         (letter_at_position(metaphone, position - 1) in @vowels and
            letter_at_position(metaphone, position + 1) in @vowels) do
      %{metaphone | next: {"H", 2}}
    else
      %{metaphone | next: {nil, 1}}
    end
  end

  def process(
        %Double{position: position, word: %Word{start_index: start_index}} = metaphone,
        character
      )
      when character == "J" do
    metaphone =
      if letter_at_position(metaphone, position, position + 4) == "JOSE" or
           letter_at_position(metaphone, start_index, start_index + 4) == "SAN " do
        if (position == start_index and letter_at_position(metaphone, position + 4) == " ") or
             letter_at_position(metaphone, start_index, start_index + 4) == "SAN " do
          %{metaphone | next: {"H", nil}}
        else
          %{metaphone | next: {"J", "H"}}
        end
      else
        if position == start_index and
             letter_at_position(metaphone, position, position + 4) != "JOSE" do
          %{metaphone | next: {"J", "A"}}
        else
          if letter_at_position(metaphone, position - 1) in @vowels and
               not Word.is_slavo_germanic?(metaphone.word) and
               letter_at_position(metaphone, position + 1) in ["A", "O"] do
            %{metaphone | next: {"J", "H"}}
          else
            if position == metaphone.word.end_index do
              %{metaphone | next: {"J", " "}}
            else
              if letter_at_position(metaphone, position + 1) not in [
                   "L",
                   "T",
                   "K",
                   "S",
                   "N",
                   "M",
                   "B",
                   "Z"
                 ] and
                   letter_at_position(metaphone, position - 1) not in ["S", "K", "L"] do
                %{metaphone | next: {"J", nil}}
              else
                %{metaphone | next: {nil, nil}}
              end
            end
          end
        end
      end

    if letter_at_position(metaphone, position + 1) == "J" do
      %{metaphone | next: Tuple.append(metaphone.next, 2)}
    else
      %{metaphone | next: Tuple.append(metaphone.next, 1)}
    end
  end

  def process(%Double{} = metaphone, character) when character == "K" do
    if letter_at_position(metaphone, metaphone.position + 1) == "K" do
      %{metaphone | next: {"K", 2}}
    else
      %{metaphone | next: {"K", 1}}
    end
  end

  def process(
        %Double{position: position, word: %Word{end_index: end_index}} = metaphone,
        character
      )
      when character == "L" do
    if letter_at_position(metaphone, position + 1) == "L" do
      if (position == end_index - 2 and
            letter_at_position(metaphone, position - 1, position + 3) in ["ILLO", "ILLA", "ALLE"]) or
           ((letter_at_position(metaphone, end_index - 1, end_index + 1) in ["AS", "OS"] or
               letter_at_position(metaphone, end_index) in ["A", "O"]) and
              letter_at_position(metaphone, position - 1, position + 3) == "ALLE") do
        %{metaphone | next: {"L", "", 2}}
      else
        %{metaphone | next: {"L", 2}}
      end
    else
      %{metaphone | next: {"L", 1}}
    end
  end

  def process(
        %Double{position: position, word: %Word{end_index: end_index}} = metaphone,
        character
      )
      when character == "M" do
    if (letter_at_position(metaphone, position + 1, position + 4) == "UMB" and
          (position + 1 == end_index or
             letter_at_position(metaphone, position + 2, position + 4) == "ER")) or
         letter_at_position(metaphone, position + 1) == "M" do
      %{metaphone | next: {"M", 2}}
    else
      %{metaphone | next: {"M", 1}}
    end
  end

  def process(%Double{position: position} = metaphone, character) when character == "N" do
    if letter_at_position(metaphone, position + 1) == "N" do
      %{metaphone | next: {"N", 2}}
    else
      %{metaphone | next: {"N", 1}}
    end
  end

  def process(%Double{position: position} = metaphone, character) when character == "P" do
    case letter_at_position(metaphone, position + 1) do
      "H" -> %{metaphone | next: {"F", 2}}
      h when h in ["P", "B"] -> %{metaphone | next: {"P", 2}}
      _ -> %{metaphone | next: {"P", 1}}
    end
  end

  def process(%Double{position: position} = metaphone, character) when character == "Q" do
    if letter_at_position(metaphone, position + 1) == "Q" do
      %{metaphone | next: {"K", 2}}
    else
      %{metaphone | next: {"K", 1}}
    end
  end

  def process(
        %Double{position: position, word: %Word{end_index: end_index}} = metaphone,
        character
      )
      when character == "R" do
    metaphone =
      if position == end_index and
           not Word.is_slavo_germanic?(metaphone.word) and
           letter_at_position(metaphone, position - 2, position) == "IE" and
           letter_at_position(metaphone, position - 4, position - 2) not in ["ME", "MA"] do
        %{metaphone | next: {"", "R"}}
      else
        %{metaphone | next: {"R", nil}}
      end

    if letter_at_position(metaphone, position + 1) == "R" do
      %{metaphone | next: Tuple.append(metaphone.next, 2)}
    else
      %{metaphone | next: Tuple.append(metaphone.next, 1)}
    end
  end

  def process(
        %Double{position: position, word: %Word{start_index: start_index, end_index: end_index}} =
          metaphone,
        character
      )
      when character == "S" do
    if letter_at_position(metaphone, position - 1, position + 2) in ["ISL", "YSL"] do
      %{metaphone | next: {nil, 1}}
    else
      if position == start_index and
           letter_at_position(metaphone, start_index, start_index + 5) == "SUGAR" do
        %{metaphone | next: {"X", "S", 1}}
      else
        if letter_at_position(metaphone, position, position + 2) == "SH" do
          if letter_at_position(metaphone, position + 1, position + 5) in [
               "HEIM",
               "HOEK",
               "HOLM",
               "HOLZ"
             ] do
            %{metaphone | next: {"S", 2}}
          else
            %{metaphone | next: {"X", 2}}
          end
        else
          if letter_at_position(metaphone, position, position + 3) in ["SIO", "SIA"] or
               letter_at_position(metaphone, position, position + 4) == "SIAN" do
            if not Word.is_slavo_germanic?(metaphone.word) do
              %{metaphone | next: {"X", "S", 3}}
            else
              %{metaphone | next: {"S", 3}}
            end
          else
            if (position == start_index and
                  letter_at_position(metaphone, position + 1) in ["M", "N", "L", "W"]) or
                 letter_at_position(metaphone, position + 1) == "Z" do
              metaphone = %{metaphone | next: {"S", "X"}}

              if letter_at_position(metaphone, position + 1) == "Z" do
                %{metaphone | next: Tuple.append(metaphone.next, 2)}
              else
                %{metaphone | next: Tuple.append(metaphone.next, 1)}
              end
            else
              if letter_at_position(metaphone, position, position + 2) == "SC" do
                if letter_at_position(metaphone, position + 2) == "H" do
                  if letter_at_position(metaphone, position + 3, position + 5) in [
                       "OO",
                       "ER",
                       "EN",
                       "UY",
                       "ED",
                       "EM"
                     ] do
                    if letter_at_position(metaphone, position + 3, position + 5) in [
                         "ER",
                         "EN"
                       ] do
                      %{metaphone | next: {"X", "SK", 3}}
                    else
                      %{metaphone | next: {"SK", 3}}
                    end
                  else
                    if position == start_index and
                         letter_at_position(metaphone, start_index + 3) not in @vowels and
                         letter_at_position(metaphone, start_index + 3) != "W" do
                      %{metaphone | next: {"X", "S", 3}}
                    else
                      %{metaphone | next: {"X", 3}}
                    end
                  end
                else
                  if letter_at_position(metaphone, position + 2) in ["I", "E", "Y"] do
                    %{metaphone | next: {"S", 3}}
                  else
                    %{metaphone | next: {"SK", 3}}
                  end
                end
              else
                if position == end_index and
                     letter_at_position(metaphone, position - 2, position) in ["AI", "OI"] do
                  %{metaphone | next: {"", "S", 1}}
                else
                  metaphone = %{metaphone | next: {"S", nil}}

                  if letter_at_position(metaphone, position + 1) in ["S", "Z"] do
                    %{metaphone | next: Tuple.append(metaphone.next, 2)}
                  else
                    %{metaphone | next: Tuple.append(metaphone.next, 1)}
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def process(
        %Double{position: position, word: %Word{start_index: start_index}} = metaphone,
        character
      )
      when character == "T" do
    if letter_at_position(metaphone, position, position + 4) == "TION" do
      %{metaphone | next: {"X", 3}}
    else
      if letter_at_position(metaphone, position, position + 3) in ["TIA", "TCH"] do
        %{metaphone | next: {"X", 3}}
      else
        if letter_at_position(metaphone, position, position + 2) == "TH" or
             letter_at_position(metaphone, position, position + 3) == "TTH" do
          if letter_at_position(metaphone, position + 2, position + 4) in ["OM", "AM"] or
               letter_at_position(metaphone, start_index, start_index + 4) in ["VON ", "VAN "] or
               letter_at_position(metaphone, start_index, start_index + 3) == "SCH" do
            %{metaphone | next: {"T", 2}}
          else
            %{metaphone | next: {"0", "T", 2}}
          end
        else
          if letter_at_position(metaphone, position + 1) in ["T", "D"] do
            %{metaphone | next: {"T", 2}}
          else
            %{metaphone | next: {"T", 1}}
          end
        end
      end
    end
  end

  def process(%Double{position: position} = metaphone, character) when character == "V" do
    if letter_at_position(metaphone, position + 1) == "V" do
      %{metaphone | next: {"F", 2}}
    else
      %{metaphone | next: {"F", 1}}
    end
  end

  def process(
        %Double{position: position, word: %Word{start_index: start_index}} = metaphone,
        character
      )
      when character == "W" do
    if letter_at_position(metaphone, position, position + 1) == "WR" do
      %{metaphone | next: {"R", 2}}
    else
      if (position == start_index and
            letter_at_position(metaphone, position + 1) in @vowels) or
           letter_at_position(metaphone, position, position + 2) == "WH" do
        if letter_at_position(metaphone, position + 1) in @vowels do
          %{metaphone | next: {"A", "F", 1}}
        else
          %{metaphone | next: {"A", 1}}
        end
      else
        if (position == metaphone.word.end_index and
              letter_at_position(metaphone, position - 1) in @vowels) or
             letter_at_position(metaphone, position - 1, position + 4) in [
               "EWSKI",
               "EWSKY",
               "OWSKI",
               "OWSKY"
             ] or
             letter_at_position(metaphone, start_index, start_index + 3) == "SCH" do
          %{metaphone | next: {"", "F", 1}}
        else
          if letter_at_position(metaphone, position, position + 4) in ["WICZ", "WITZ"] do
            %{metaphone | next: {"TS", "FX", 4}}
          else
            %{metaphone | next: {nil, 1}}
          end
        end
      end
    end
  end

  def process(%Double{position: position} = metaphone, character) when character == "X" do
    metaphone = %{metaphone | next: {nil, nil}}

    metaphone =
      if not ((position == metaphone.word.end_index and
                 letter_at_position(metaphone, position - 3, position) in ["IAU", "EAU"]) or
                letter_at_position(metaphone, position - 2, position) in ["AU", "OU"]) do
        %{metaphone | next: {"KS", nil}}
      else
        metaphone
      end

    if letter_at_position(metaphone, position + 1) in ["C", "X"] do
      %{metaphone | next: Tuple.append(metaphone.next, 2)}
    else
      %{metaphone | next: Tuple.append(metaphone.next, 1)}
    end
  end

  def process(%Double{position: position} = metaphone, character) when character == "Z" do
    metaphone =
      if letter_at_position(metaphone, position + 1) == "H" do
        %{metaphone | next: {"J", nil}}
      else
        if letter_at_position(metaphone, position + 1, position + 3) in [
             "ZO",
             "ZI",
             "ZA"
           ] or
             (Word.is_slavo_germanic?(metaphone.word) and
                position > metaphone.word.start_index and
                letter_at_position(metaphone, position - 1) != "T") do
          %{metaphone | next: {"S", "TS"}}
        else
          %{metaphone | next: {"S", nil}}
        end
      end

    if letter_at_position(metaphone, position + 1) == "Z" or
         letter_at_position(metaphone, position + 1) == "H" do
      %{metaphone | next: Tuple.append(metaphone.next, 2)}
    else
      %{metaphone | next: Tuple.append(metaphone.next, 1)}
    end
  end

  def process(%Double{} = metaphone, _character) do
    %{metaphone | next: {nil, 1}}
  end

  @doc """
  Accept two lists. Loop through a cartesian product of the two lists. Using a
  reducer, iterate over the levels. For each level, compare the item
  sets using compare/3. The first, if any, level to return a true value
  from compare/3 stops the reducer and percentage of true values found.
  Otherwise the reducer continues. 0 is returned if no comparison returns
  true at any level.

  - "strict": both encodings for each string must match
  - "strong": the primary encoding for each string must match
  - "normal": the primary encoding of one string must match either encoding of other string (default)
  - "weak":   either primary or secondary encoding of one string must match one encoding of other string
  """
  def substring_compare(left, right, _opts) when left == [] or right == [], do: 0

  def substring_compare(left, right, _opts) when is_list(left) and is_list(right) do
    Enum.reduce_while(["strict", "strong", "normal", "weak"], 0, fn level, acc ->
      scores =
        for l <- left, r <- right do
          Akin.Metaphone.Double.compare(l, r, level)
        end

      size = Enum.min([Enum.count(left), Enum.count(right)])

      (Enum.count(scores, fn s -> s == true end) / size)
      |> case do
        score when score > 0 -> {:halt, score}
        _ -> {:cont, acc}
      end
    end)
  end

  defp initial_process(metaphone, position, character) when character in @vowels do
    process_initial_vowels(metaphone, position)
  end

  defp initial_process(metaphone, _position, character) do
    process(metaphone, character)
  end

  defp build_phones(%Double{next: {nil, next}, position: position} = metaphone) do
    %{metaphone | position: position + next}
  end

  defp build_phones(%Double{next: {a, next}, position: position} = metaphone) do
    primary_phone = metaphone.primary_phone <> a
    secondary_phone = metaphone.secondary_phone <> a

    %{
      metaphone
      | position: position + next,
        primary_phone: primary_phone,
        secondary_phone: secondary_phone
    }
  end

  defp build_phones(%Double{next: {nil, nil, next}, position: position} = metaphone) do
    %{metaphone | position: position + next}
  end

  defp build_phones(%Double{next: {nil, b, next}, position: position} = metaphone) do
    secondary_phone = metaphone.secondary_phone <> b
    %{metaphone | position: position + next, secondary_phone: secondary_phone}
  end

  defp build_phones(%Double{next: {a, nil, next}, position: position} = metaphone) do
    primary_phone = metaphone.primary_phone <> a
    secondary_phone = metaphone.secondary_phone <> a

    %{
      metaphone
      | position: position + next,
        primary_phone: primary_phone,
        secondary_phone: secondary_phone
    }
  end

  defp build_phones(%Double{next: {a, b, next}, position: position} = metaphone) do
    primary_phone = metaphone.primary_phone <> a
    secondary_phone = metaphone.secondary_phone <> b

    %{
      metaphone
      | position: position + next,
        primary_phone: primary_phone,
        secondary_phone: secondary_phone
    }
  end

  defp build_phones(%Double{position: position} = metaphone) do
    %{metaphone | position: position + 1}
  end

  defp return_phones({a, b}), do: {String.downcase(a), String.downcase(b)}

  defp parse_next(%Double{} = metaphone) do
    position = metaphone.position
    end_index = metaphone.word.end_index
    character = letter_at_position(metaphone, position)
    parse(metaphone, position, end_index, character)
  end

  def letter_at_position(%Double{} = metaphone, start_position) do
    String.slice(metaphone.word.buffer, start_position, 1)
  end

  def letter_at_position(%Double{} = metaphone, start_position, close_position) do
    String.slice(metaphone.word.buffer, start_position, close_position - start_position)
  end
end
