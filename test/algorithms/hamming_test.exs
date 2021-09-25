defmodule HammingTest do
  use ExUnit.Case
  import Akin.Hamming, only: [compare: 2]
  alias Akin.Primed

  test "returns nil with empty arguments" do
    assert compare(%Primed{string: ""}, %Primed{string: ""}) == nil
    assert compare(%Primed{string: "abc"}, %Primed{string: ""}) == nil
    assert compare(%Primed{string: ""}, %Primed{string: "xyz"}) == nil
  end

  test "return nil with unequal string length arguments" do
    assert compare(%Primed{string: "abc"}, %Primed{string: "wxyz"}) == nil
    assert compare(%Primed{string: "123"}, %Primed{string: "3456"}) == nil
    assert compare(%Primed{string: "fff"}, %Primed{string: "xxxx"}) == nil
  end

  test "return 0 with equal arguments" do
    assert compare(%Primed{string: "abc"}, %Primed{string: "abc"}) == 0
    assert compare(%Primed{string: "123"}, %Primed{string: "123"}) == 0
  end

  test "return distance with unequal arguments" do
    assert compare(%Primed{string: "abc"}, %Primed{string: "xyz"}) == 3
    assert compare(%Primed{string: "123"}, %Primed{string: "456"}) == 3
    assert compare(%Primed{string: "fff"}, %Primed{string: "xxx"}) == 3
  end

  test "returns distance with valid arguments" do
    assert compare(%Primed{string: "toned"}, %Primed{string: "roses"}) == 3
    assert compare(%Primed{string: "1011101"}, %Primed{string: "1001001"}) == 2
    assert compare(%Primed{string: "2173896"}, %Primed{string: "2233796"}) == 3
  end
end
