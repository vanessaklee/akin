defmodule DocTest do
  use ExUnit.Case
  doctest Akin.Metaphone.Metaphone
  doctest Akin.Metaphone
  doctest Akin.DiceSorensen
  doctest Akin.Hamming
  doctest Akin.Jaccard
  doctest Akin.JaroWinkler
  doctest Akin.Levenshtein
  doctest Akin.Ngram
  doctest Akin.Overlap
  doctest Akin.Tversky
  doctest Akin.And
  doctest Akin.Util
end
