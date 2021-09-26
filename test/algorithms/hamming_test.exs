defmodule HammingTest do
  use ExUnit.Case
  import Akin.Hamming, only: [compare: 2]
  alias Akin.Corpus

  test "returns nil with empty arguments" do
    assert compare(%Corpus{string: ""}, %Corpus{string: ""}) == nil
    assert compare(%Corpus{string: "abc"}, %Corpus{string: ""}) == nil
    assert compare(%Corpus{string: ""}, %Corpus{string: "xyz"}) == nil
  end

  test "return nil with unequal string length arguments" do
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "wxyz"}) == nil
    assert compare(%Corpus{string: "123"}, %Corpus{string: "3456"}) == nil
    assert compare(%Corpus{string: "fff"}, %Corpus{string: "xxxx"}) == nil
  end

  test "return 0 with equal arguments" do
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "abc"}) == 0
    assert compare(%Corpus{string: "123"}, %Corpus{string: "123"}) == 0
  end

  test "return distance with unequal arguments" do
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "xyz"}) == 3
    assert compare(%Corpus{string: "123"}, %Corpus{string: "456"}) == 3
    assert compare(%Corpus{string: "fff"}, %Corpus{string: "xxx"}) == 3
  end

  test "returns distance with valid arguments" do
    assert compare(%Corpus{string: "toned"}, %Corpus{string: "roses"}) == 3
    assert compare(%Corpus{string: "1011101"}, %Corpus{string: "1001001"}) == 2
    assert compare(%Corpus{string: "2173896"}, %Corpus{string: "2233796"}) == 3
  end
end
