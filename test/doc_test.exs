defmodule DocTest do
  use ExUnit.Case
  doctest Akin.Phonetic.MetaphoneAlgorithm
  doctest Akin.Similarity.MetaphoneExact
  doctest Akin.Similarity.MetaphoneScores
  doctest Akin.Similarity.DiceSorensen
  doctest Akin.Similarity.Hamming
  doctest Akin.Similarity.Jaccard
  doctest Akin.Similarity.JaroWinkler
  doctest Akin.Similarity.Levenshtein
  doctest Akin.Similarity.Ngram
  doctest Akin.Similarity.Overlap
  doctest Akin.Similarity.Tversky
  doctest Akin.And
  doctest Akin.Util
  doctest Akin.AuthorUtil
end
