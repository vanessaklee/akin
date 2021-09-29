defmodule DoubleMetaphoneTest do
  use ExUnit.Case
  import Akin.DoubleMetaphone, only: [compare: 2]

  test "return the expected boolean on comparison with default/normal match_level" do
    assert compare("judge", "juge") == 1.0
    assert compare("judge", "jawge") == 1.0
    assert compare("knock", "nock") == 1.0
    assert compare("white", "wite") == 1.0
    assert compare("pear", "pair") == 1.0
    assert compare("board", "bored") == 1.0

    assert compare("wood", "would") == 0.0
  end

  test "returns expected boolean with bad values" do
    assert compare("toned", "roses") == 0.0
    assert compare("2173896", "2233796") == 0.0
    assert compare("1011101", "1011101") == 0.0
  end
end
