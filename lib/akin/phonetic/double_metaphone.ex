# defmodule Akin.Phonetic.DoubleMetaphone do
#   @moduledoc """
#   The original Metaphone algorithm was published in 1990 as an improvement over
#   the Soundex algorithm. Like Soundex, it was limited to English-only use. The
#   Metaphone algorithm does not produce phonetic representations of an input word
#   or name; rather, the output is an intentionally approximate phonetic
#   representation. The approximate encoding is necessary to account for the way
#   speakers vary their pronunciations and misspell or otherwise vary words and
#   names they are trying to spell.
#   The Double Metaphone phonetic encoding algorithm is the second generation of
#   the Metaphone algorithm. Its implementation was described in the June 2000
#   issue of C/C++ Users Journal. It makes a number of fundamental design
#   improvements over the original Metaphone algorithm.
#   It is called "Double" because it can return both a primary and a secondary code
#   for a string; this accounts for some ambiguous cases as well as for multiple
#   variants of surnames with common ancestry. For example, encoding the name
#   "Smith" yields a primary code of SM0 and a secondary code of XMT, while the
#   name "Schmidt" yields a primary code of XMT and a secondary code of SMT--both
#   have XMT in common.
#   Double Metaphone tries to account for myriad irregularities in English of
#   Slavic, Germanic, Celtic, Greek, French, Italian, Spanish, Chinese, and other
#   origin. Thus it uses a much more complex ruleset for coding than its
#   predecessor; for example, it tests for approximately 100 different contexts of
#   the use of the letter C alone.
#   This script implements the Double Metaphone algorithm (c) 1998, 1999 originally
#   implemented by Lawrence Philips in C++. It was further modified in C++ by Kevin
#   Atkinson (http://aspell.net/metaphone/). It was translated to C by Maurice
#   Aubrey <maurice@hevanet.com> for use in a Perl extension. A Python version was
#   created by Andrew Collins on January 12, 2007, using the C source
#   (http://www.atomodo.com/code/double-metaphone/metaphone.py/view).
#   """
#   @vowels ["A", "E", "I", "O", "U", "Y"]
#   @silent_starters ["GN", "KN", "PN", "WR", "PS"]
#   @prepad "  "
#   @postpad "      "

#   alias Akin.Util

#   @doc """
#     Compares two values phonetically and returns a boolean of whether they match
#     or not.
#     ## Examples
#       iex> Akin.Phonetic.MetaphoneMetric.compare("Colorado", "Kolorado")s
#       true
#       iex> Akin.Phonetic.MetaphoneMetric.compare("Moose", "Elk")
#       false
#   """
#   def compare(left, right) do
#     case Util.len(left) == 0 ||
#          !Util.is_alphabetic?(String.first(left)) ||
#          Util.len(right) == 0 ||
#          !Util.is_alphabetic?(String.first(right)) do
#       false ->
#         compute(left) == compute(right)

#       true ->
#         nil
#     end
#   end

#   @doc """
#     Returns the Metaphone phonetic version of the provided string.
#     ## Examples
#       iex> Akin.Phonetic.DoubleMetaphone.compute("z")
#       "s"
#       iex> Akin.Phonetic.DoubleMetaphone.compute("ztiaz")
#       "sxs"
#   """
#   def compute(value) do
#     cond do
#       Util.len(value) == 0 ->
#         nil

#       !Util.is_alphabetic?(value) ->
#         nil

#       true ->
#         value
#         |> String.downcase
#         # |> transcode_first_character
#         # |> deduplicate
#         # |> transcode
#     end
#   end

#   def position(word) do
#     # skip these silent letters when at start of word
#     add_on1 = if get_letters(word, 0, 2) in @silent_starters, do: 1, else: 0
#     add_on2 = if get_letters(word, 0, 1) == "X", do: 1, else: 0

#     add_on1 + add_on2
#   end

#   def normalize(word) do
#     word
#     |> filter_mn_category()
#     |> String.replace("Ç", "s")
#     |> String.replace("ç", "s")
#     |> String.normalize(:nfd)
#   end

#   def buffer(word) do
#     @prepad <> String.upcase(word) <> @postpad
#   end

#   def word_map(word) do
#     upper = String.upcase((word))
#     start_index = String.length(@prepad)
#     length = String.length(upper)
#     p = word |> normalize() |> position()
#     next = if p == start_index, do: {"A", 1}, else: {"None", 1}
#     %{
#       upper: upper,
#       length: length,
#       start_index: start_index,
#       end_index: start_index + length - 1,
#       buffer: buffer(word),
#       position: p,
#       next: next
#     }
#   end

#   def get_letters(word, start, nil), do: get_letters(word, start, start+1)
#   def get_letters(word, start, stop) when is_binary(word) do
#     start_index = String.length(@prepad)
#     normalize(word)
#     |> String.upcase()
#     |> buffer()
#     |> String.slice(start_index + start, start_index + stop)
#   end
#   def get_letters(_, _, _), do: ""

#   def primary_phone(word) do
#     if get_letters(word, 0, 2) == "X", do: "S", else: ""
#   end

#   def filter_mn_category(word) do
#     word
#     |> String.graphemes()
#     |> Enum.filter(fn char ->
#       # remove Nonspacing Mark characters
#       :Mn not in Unicode.category(char)
#     end)
#     |> Enum.join("")
#   end

#   def is_slavo_germanic?(word) do
#     word_list = word |> String.upcase() |> String.graphemes()
#     Enum.any?(["W", "K", "CZ", "WITZ"], fn sg -> sg in word_list end)
#   end

#   def sequence(word, start), do: String.at(word, start)

#   def sequence(word, start, stop), do: String.slice(word, start, stop)

#   def process_b(word_map) when is_map(word_map) do
#     # "-mb", e.g., "dumb", already skipped over... see "M" below
#     if sequence(word_map.buffer, word_map.position + 1) == "B" do
#       Map.put(word_map, :next, {"P", 2})
#     else
#       Map.put(word_map, :next, {"P", 1})
#     end
#   end

#   def process_c(word_map) when is_map(word_map) do
#     buffer = word_map.buffer
#     position = word_map.position
#     start_index = word_map.start_index
#     # various germanic
#     cond do
#       position > start_index + 1
#       and sequence(buffer, position - 2) not in @vowels
#       and sequence(buffer, position - 1, word_map.position + 2) == "ACH"
#       and sequence(buffer, position + 2) not in ["I"]
#       and (
#         sequence(buffer, position + 2) not in ["E"]
#         or sequence(buffer, position - 2, position + 4) in ["BACHER", "MACHER"]
#       ) ->

#         Map.put(word_map, :next, {"K", 2})

#       # special case "CAESAR"
#       position == start_index
#       and sequence(buffer, start_index, start_index + 6) == "CAESAR" ->

#         Map.put(word_map, :next, {"K", 2})

#       # italian "chianti"
#       sequence(buffer, position, position + 4) == "CHIA" ->

#         Map.put(word_map, :next, {"K", 2})

#       sequence(buffer, position, position + 2) == "CH" ->

#         cond do
#           # find "michael"
#           position > start_index
#           and sequence(buffer, position, position + 4) == "CHAE" ->
#               Map.put(word_map, :next, {"K", "X", 2})

#           position == start_index
#           and (
#             sequence(buffer, position + 1, position + 6) in ["HARAC", "HARIS"]
#             or sequence(buffer, position + 1, position + 4) in ["HOR", "HYM", "HIA", "HEM"]
#           )
#           and sequence(buffer, start_index, start_index + 5) != "CHORE" ->
#               Map.put(word_map, :next, {"K", 2})

#           # germanic, greek, or otherwise "ch" for "kh" sound
#           sequence(buffer, start_index, start_index + 4) in ["VAN ", "VON "]
#           or sequence(buffer, start_index, start_index + 3) == "SCH"
#           or sequence(buffer, position - 2, position + 4) in ["ORCHES", "ARCHIT", "ORCHID"]
#           or sequence(buffer, position + 2) in ["T", "S"]
#           or (
#               (
#                 sequence(buffer, position - 1) in ["A", "O", "U", "E"]
#                 or position == start_index
#               )
#               and sequence(buffer, position + 2) in ["L", "R", "N", "M", "B", "H", "F", "V", "W", " "]
#           ) ->
#               Map.put(word_map, :next, {"K", 2})

#           true ->
#             if position > start_index do
#               if sequence(buffer, start_index, start_index + 2) == "MC" do
#                 Map.put(word_map, :next, {"K", 2})
#               else
#                 Map.put(word_map, :next, {"K", "K", 2})
#               end
#             else
#               Map.put(word_map, :next, {"K", 2})
#             end
#         end

#     # e.g, "czerny"
#     sequence(buffer, position, position + 2) == "CZ"
#     and sequence(buffer, position - 2, position + 2) != "WICZ" ->

#       Map.put(word_map, :next, {"K", "X", 2})

#     # e.g., "focaccia"
#     sequence(buffer, position + 1, position + 4) == "CIA" ->

#       Map.put(word_map, :next, {"K", 3})

#     # double "C", but not if e.g. "McClellan"
#     sequence(buffer, position, position + 2) == "CC"
#     and not (
#       position == (start_index + 1)
#       and sequence(buffer, start_index) == "M"
#     ) ->

#       #"bellocchio" but not "bacchus"
#       if sequence(buffer, position + 2) in ["I", "E", "H"]
#         and sequence(buffer, position + 2, position + 4) != "HU" do

#           # "accident", "accede" "succeed"
#           if (
#               position == (start_index + 1)
#               and sequence(buffer, start_index) == "A"
#             )
#             or sequence(buffer, position - 1, position + 4) in ["UCCEE", "UCCES"] do

#               Map.put(word_map, :next, {"K", 3})
#           else
#             # "bacci", "bertucci", other italian
#             Map.put(word_map, :next, {"K", 3})
#           end
#       else
#         Map.put(word_map, :next, {"K", 2})
#       end

#     sequence(buffer, position, position + 2) in ["CK", "CG", "CQ"] ->

#       Map.put(word_map, :next, {"K", 2})

#     sequence(buffer, position, position + 2) in ["CI", "CE", "CY"] ->

#       # italian vs. english
#       if sequence(buffer, position, position + 3) in ["CIO", "CIE", "CIA"] do
#         Map.put(word_map, :next, {"K", "X", 2})
#       else
#         Map.put(word_map, :next, {"K", 2})
#       end

#     true ->
#       # name sent in "mac caffrey", "mac gregor"
#       if sequence(buffer, position + 1, position + 3) in [" C", " Q", " G"] do
#         Map.put(word_map, :next, {"K", 3})
#       else
#         if sequence(buffer, position + 1) in ["C", "K", "Q"]
#           and sequence(buffer, position + 1, position + 3) not in ["CE", "CI"] do
#             Map.put(word_map, :next, {"K", 2})
#         else
#           # default for "C"
#           Map.put(word_map, :next, {"K", 2})
#         end
#       end
#     end
#   end

#   def process_d(word_map) do
#     buffer = word_map.buffer
#     position = word_map.position
#     cond do
#       sequence(buffer, position, position + 2) == "DG" ->
#         # e.g. "edge"
#         if sequence(buffer, position + 2) in ["I", "E", "Y"] do
#           Map.put(word_map, :next, {"J", 3})
#         else
#           Map.put(word_map, :next, {"TK", 2})

#         end

#       sequence(buffer, position, position + 2) in ["DT", "DD"] ->
#         Map.put(word_map, :next, {"T", 2})

#       true ->
#         Map.put(word_map, :next, {"T", 1})
#     end
#   end

#   def process_f(word_map) do
#     buffer = word_map.buffer
#     position = word_map.position

#     if sequence(buffer, position + 1) == "F" do
#       Map.put(word_map, :next, {"F", 2})
#     else
#       Map.put(word_map, :next, {"F", 1})

#     end
#   end

#   def process_j(word_map) do
#     buffer = word_map.buffer
#     position = word_map.position
#     start_index = word_map.start_index

#     # obvious spanish, "jose", "san jacinto"
#     cond do
#       sequence(buffer, position, position + 4) == "JOSE"
#       or sequence(buffer, start_index, start_index + 4) == "SAN ") ->
#         if (
#             position == start_index and sequence(buffer, position + 4) == " ")
#             or sequence(buffer, start_index, start_index + 4) == "SAN " do
#           Map.put(word_map, :next, {"H", nil})
#         else
#             Map.put(word_map, :next, {"J", "H"})
#         end

#         # Yankelovich/Jankelowicz
#       position == start_index and sequence(buffer, position, position + 4) != "JOSE" ->
#         Map.put(word_map, :next, {"J", "A"})

#       true ->
#           # spanish pron. of e.g. "bajador"
#           if sequence(buffer, position - 1) in @vowels
#               and not self.word.is_slavo_germanic
#               and sequence(buffer, position + 1) in ["A", "O"]) do
#               Map.put(word_map, :next, {"J", "H"})
#           else
#               if position == word_map.end_index do
#                 Map.put(word_map, :next, {"J", " "})
#               else
#                   if sequence(buffer, position + 1] not in ["L", "T", "K", "S", "N", "M", "B", "Z"]
#                      and sequence(buffer, position - 1] not in ["S", "K", "L"]) do
#                     Map.put(word_map, :next, {"J", nil})
#                   else
#                     Map.put(word_map, :next, {"None", nil})
#                   end
#               end
#           end
#       end

#       if sequence(buffer, position + 1] == "J" do
#         # TODO this is being handled incorrectly here; fix it?
#         self.next = self.next + (2,)
#       else
#         self.next = self.next + (1,)
#       end
#   end

#   def process_h(word_map) do
#     buffer = word_map.buffer
#     position = word_map.position
#     # only keep if self.word.start_index & before vowel or btw. 2 vowels
#     if sequence(buffer, position + 1) in VOWELS and (
#         position == word_map.start_index
#         or sequence(buffer, position - 1) in VOWELS
#       ) do
#         Map.put(word_map, :next, {"H", 2})
#     # (also takes care of "HH")
#     else
#       Map.put(word_map, :next, {"None", 1})
#     end
#   end
# end
