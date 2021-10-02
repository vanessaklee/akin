defmodule DoubleMetaphoneTest do
  use ExUnit.Case
  import Akin.DoubleMetaphone, only: [compare: 2]
  import Akin.Util, only: [compose: 1]

  test "return the expected boolean on comparison with default/normal match_level" do
    assert compare(compose("judge"), compose("juge")) ==  1.0
    assert compare(compose("judge"), compose("jawge")) ==  1.0
    assert compare(compose("knock"), compose("nock")) ==  1.0
    assert compare(compose("white"), compose("wite")) ==  1.0
    assert compare(compose("pear"), compose("pair")) ==  1.0
    assert compare(compose("board"), compose("bored")) ==  1.0

    assert compare(compose("wood"), compose("would")) ==  0.0
  end

  test "returns expected boolean with bad values" do
    assert compare(compose("toned"), compose("roses")) ==  0.0
    assert compare(compose("2173896"), compose("2233796")) ==  0.0
    assert compare(compose("1011101"), compose("1011101")) ==  0.0
  end
end
