defmodule AkinTest do
  use ExUnit.Case
  import Akin
  import Akin.Util

  test "requesting a subset of algorithms in the options results in expected phonetic algorithms" do
    all_phonetic = list_algorithms([algorithms: [metric: "phonetic"]])
    whole_phonetic = list_algorithms([algorithms: [metric: "phonetic", unit: "whole"]])
    partial_phonetic = list_algorithms([algorithms: [metric: "phonetic", unit: "partial"]])

    assert all_phonetic == ["double_metaphone", "metaphone", "substring_double_metaphone"]
    assert whole_phonetic == ["double_metaphone", "metaphone"]
    assert partial_phonetic == ["substring_double_metaphone"]
  end

  test "requesting a subset of whole string algorithms in the options results in expected string algorithms" do
    whole_string = list_algorithms([algorithms: [metric: "string", unit: "whole"]])

    assert whole_string == ["bag_distance", "jaccard", "jaro_winkler", "levenshtein", "sorensen_dice", "tversky"]
  end

  test "requesting a subset of partial string algorithms in the options results in expected string algorithms" do
    partial_string = list_algorithms([algorithms: [metric: "string", unit: "partial"]])

    assert partial_string == ["ngram", "overlap", "substring_set", "substring_sort"]
  end

  test "requesting a subset of string algorithms in the options results in expected string algorithms" do
    all_string = list_algorithms([algorithms: [metric: "string"]])

    assert all_string == [
        "bag_distance",
        "jaccard",
        "jaro_winkler",
        "levenshtein",
        "ngram",
        "overlap",
        "sorensen_dice",
        "substring_set",
        "substring_sort",
        "tversky"
      ]
  end

  test "requesting a subset of algorithms in the options results in expected subset of algorithms" do
    a = ["bag_distance", "metaphone", "substring_sort"]
    a_set = list_algorithms([algorithms: a])
    b = ["overlap", "substring_double_metaphone"]
    b_set = list_algorithms([algorithms: b])

    assert a_set == a
    assert b_set == b
  end

  test "comparing two exact strings returns all 1.0 values" do
    results = compare("Alice", "Alice", [])

    assert Enum.all?(results, fn {_k, v} -> v == 1.0 end)
  end

  test "comparing a name against a list of names in which that name appears, returns a match" do
    assert match_names("alice", ["alice"]) == ["alice"]
  end

  test "comparing a name with initials matches names with all of those initials match" do
    names_to_match = ["a liddell"]
    results = match_names("a p liddell", names_to_match)

    expected = names_to_match -- ["alice b liddell"]

    assert Enum.all?(results, fn r -> r in expected end)
  end
end
