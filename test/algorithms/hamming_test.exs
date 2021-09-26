defmodule HammingTest do
  use ExUnit.Case
  import Akin.Hamming, only: [compare: 3]

  test "returns 0.0 with empty arguments" do
    assert compare(Akin.Util.compose(""), Akin.Util.compose(""), []) == 0.0
    assert compare(Akin.Util.compose("abc"), Akin.Util.compose(""), []) == 0.0
    assert compare(Akin.Util.compose(""), Akin.Util.compose("xyz"), []) == 0.0
  end

  test "return 0.0 with unequal string length arguments" do
    assert compare(Akin.Util.compose("abc"), Akin.Util.compose("wxyz"), []) == 0.0
  end

  test "return 0.0 with equal arguments" do
    assert compare(Akin.Util.compose("abc"), Akin.Util.compose("abc"), []) == 1.0
    assert compare(Akin.Util.compose("123"), Akin.Util.compose("123"), []) == 1.0
  end

  test "return distance with unequal arguments" do
    assert compare(Akin.Util.compose("abc"), Akin.Util.compose("xyz"), []) == 0.0
    assert compare(Akin.Util.compose("123"), Akin.Util.compose("456"), []) == 0.0
    assert compare(Akin.Util.compose("fff"), Akin.Util.compose("xxx"), []) == 0.0
  end

  test "returns distance with valid arguments" do
    assert compare(Akin.Util.compose("toned"), Akin.Util.compose("roses"), []) == 0.4
    assert compare(Akin.Util.compose("toned"), Akin.Util.compose("toned"), []) == 1.0
    assert compare(Akin.Util.compose("1011101"), Akin.Util.compose("1001001"), []) |> Float.round(2) == 0.71
    assert compare(Akin.Util.compose("2173896"), Akin.Util.compose("2233796"), []) |> Float.round(2) == 0.57
    assert compare(Akin.Util.compose("2173896"), Akin.Util.compose("2233796"), []) |> Float.round(2) == 0.57
  end
end
