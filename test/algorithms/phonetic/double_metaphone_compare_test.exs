defmodule DoubleCompareTest do
  use ExUnit.Case

  import Akin.Metaphone.Double

  test "return the expected boolean on comparison with default/normal threshold" do
    assert compare(parse("judge"), parse("juge"))
    assert compare(parse("judge"), parse("jawge"))
    assert compare(parse("knock"), parse("nock"))
    assert compare(parse("white"), parse("wite"))
    assert compare(parse("pear"), parse("pair"))
    assert compare(parse("board"), parse("bored"))

    refute compare(parse("wood"), parse("would"))
  end

  test "return the expected boolean on comparison with weak threshold" do
    assert compare(parse("judge"), parse("juge"), "weak")
    assert compare(parse("judge"), parse("jawge"), "weak")
    assert compare(parse("knock"), parse("nock"))
    assert compare(parse("white"), parse("wite"))
    assert compare(parse("pear"), parse("pair"))
    assert compare(parse("board"), parse("bored"))

    refute compare(parse("wood"), parse("would"))
  end

  test "return the expected boolean on comparison with strong threshold" do
    assert compare(parse("judge"), parse("juge"), "strong")
    assert compare(parse("judge"), parse("jawge"), "strong")
    assert compare(parse("knock"), parse("nock"))
    assert compare(parse("white"), parse("wite"))
    assert compare(parse("pear"), parse("pair"))
    assert compare(parse("board"), parse("bored"))

    refute compare(parse("wood"), parse("would"))
  end

  test "return the expected boolean on comparison with strict threshold" do
    refute compare(parse("judge"), parse("juge"), "strict")
    refute compare(parse("judge"), parse("jawge"), "strict")
    refute compare(parse("wood"), parse("would"))

    assert compare(parse("knock"), parse("nock"))
    assert compare(parse("white"), parse("wite"))
    assert compare(parse("pear"), parse("pair"))
    assert compare(parse("board"), parse("bored"))
  end
end
