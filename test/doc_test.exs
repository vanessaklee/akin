defmodule DocTest do
  use ExUnit.Case
  doctest Akin.Phonetic.MetaphoneAlgorithm
  doctest Akin.Phonetic.MetaphoneMetric
  doctest Akin.Similarity.DiceSorensen
  doctest Akin.Similarity.Hamming
  doctest Akin.Similarity.Jaccard
  doctest Akin.Similarity.JaroWinkler
  doctest Akin.Similarity.Levenshtein
  doctest Akin.Similarity.NGram
  doctest Akin.Similarity.Overlap
  doctest Akin.Similarity.Tversky
  doctest Akin.Util
end
