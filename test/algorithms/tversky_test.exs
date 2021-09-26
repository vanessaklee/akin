defmodule TverskyTest do
  use ExUnit.Case
  import Akin.Tversky
  alias Akin.Corpus

  @test_options [ngram_size: 3]
  @adv_test_options [ngram_size: 4]

  test "returns nil with empty arguments" do
    assert compare(%Corpus{string: ""}, %Corpus{string: ""}) == nil
    assert compare(%Corpus{string: "abc"}, %Corpus{string: ""}) == nil
    assert compare(%Corpus{string: ""}, %Corpus{string: "xyz"}) == nil
  end

  test "return 1 with equal arguments" do
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "abc"}, @test_options) == 1
    assert compare(%Corpus{string: "123"}, %Corpus{string: "123"}, @test_options) == 1
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "abc"}) == 1
    assert compare(%Corpus{string: "123"}, %Corpus{string: "123"}) == 1
  end

  test "return 0 with unequal arguments" do
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "xyz"}, @test_options) == 0
    assert compare(%Corpus{string: "123"}, %Corpus{string: "456"}, @test_options) == 0
    assert compare(%Corpus{string: "fff"}, %Corpus{string: "xxx"}, @test_options) == 0
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "xyz"}) == 0
    assert compare(%Corpus{string: "123"}, %Corpus{string: "456"}) == 0
    assert compare(%Corpus{string: "fff"}, %Corpus{string: "xxx"}) == 0
  end

  test "returns nil with invalid arguments" do
    assert compare(%Corpus{string: "n"}, %Corpus{string: "naght"}, @test_options) == nil
    assert compare(%Corpus{string: "night"}, %Corpus{string: "n"}, @test_options) == nil
    assert compare(%Corpus{string: "ni"}, %Corpus{string: "naght"}, @adv_test_options) == nil
    assert compare(%Corpus{string: "night"}, %Corpus{string: "na"}, @adv_test_options) == nil
  end
end
