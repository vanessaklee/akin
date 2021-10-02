defmodule HammingTest do
  use ExUnit.Case
  import Akin.Hamming, only: [compare: 3]
  import Akin.Util, only: [compose: 1]

  test "returns 0.0 with empty arguments" do
    assert compare(compose(""), compose(""), []) == nil
    assert compare(compose("abc"), compose(""), []) == nil
  end

  test "return 0.0 with unequal string length arguments" do
    assert compare(compose("abc"), compose("wxyz"), []) == nil
  end

  test "return 0.0 with equal arguments" do
    assert compare(compose("abc"), compose("abc"), []) == 0.0
    assert compare(compose("123"), compose("123"), []) == 0.0
  end

  test "return distance with unequal arguments" do
    assert compare(compose("abc"), compose("xyz"), []) == 1.0
    assert compare(compose("123"), compose("456"), []) == 1.0
  end

  test "returns distance with valid arguments" do
    assert compare(compose("toned"), compose("roses"), []) == 0.6
    assert compare(compose("1011101"), compose("1001001"), []) |> Float.round(2) == 0.29
    assert compare(compose("2173896"), compose("2233796"), []) |> Float.round(2) == 0.43
  end
end
