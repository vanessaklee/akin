defmodule MetaphoneMetricTest do
  use ExUnit.Case

  import Akin.Metaphone, only: [compare: 2]

  test "returns nil with empty argument" do
    assert compare("", "") == nil
    assert compare("abc", "") == nil
    assert compare("", "xyz") == nil
  end

  test "returns nil with non-phonetic arguments" do
    assert compare("123", "123") == nil
    assert compare("123", "") == nil
    assert compare("", "123") == nil
  end

  test "returns true with phonetically similar arguments" do
    assert compare("dumb", "dum") == 1
    assert compare("smith", "smeth") == 1
    assert compare("merci", "mercy") == 1
  end

  test "returns false with phonetically dissimilar arguments" do
    assert compare("dumb", "gum") == 0
    assert compare("smith", "kiss") == 0
    assert compare("merci", "burpy") == 0
  end
end
