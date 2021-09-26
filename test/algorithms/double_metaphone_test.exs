defmodule DoubleMetaphoneTest do
  use ExUnit.Case
  import Akin.DoubleMetaphone, only: [compare: 2, compare: 3]

  test "return the expected boolean on comparison with default/normal threshold" do
    assert compare("judge", "juge") == 1.0
    assert compare("judge", "jawge") == 1.0
    assert compare("knock", "nock") == 1.0
    assert compare("white", "wite") == 1.0
    assert compare("pear", "pair") == 1.0
    assert compare("board", "bored") == 1.0

    assert compare("wood", "would") == 0.0
  end

  test "returns expected boolean with bad values" do
    assert compare(Akin.Util.compose("toned"), Akin.Util.compose("roses"), []) == 0.0
    assert compare(Akin.Util.compose("2173896"), Akin.Util.compose("2233796"), []) == 0.0
    assert compare(Akin.Util.compose("1011101"), Akin.Util.compose("1011101"), []) == 0.0
  end
end
