defmodule TverskyTest do
  use ExUnit.Case
  import Akin.Tversky, only: [compare: 2, compare: 3]
  alias Akin.Primed

  @test_options [ngram_size: 3]
  @adv_test_options [ngram_size: 4]

  test "returns nil with empty arguments" do
    assert compare(%Primed{string: ""}, %Primed{string: ""}) == nil
    assert compare(%Primed{string: "abc"}, %Primed{string: ""}) == nil
    assert compare(%Primed{string: ""}, %Primed{string: "xyz"}) == nil
  end

  test "return 1 with equal arguments" do
    assert compare(%Primed{string: "abc"}, %Primed{string: "abc"}, @test_options) == 1
    assert compare(%Primed{string: "123"}, %Primed{string: "123"}, @test_options) == 1
    assert compare(%Primed{string: "abc"}, %Primed{string: "abc"}) == 1
    assert compare(%Primed{string: "123"}, %Primed{string: "123"}) == 1
  end

  test "return 0 with unequal arguments" do
    assert compare(%Primed{string: "abc"}, %Primed{string: "xyz"}, @test_options) == 0
    assert compare(%Primed{string: "123"}, %Primed{string: "456"}, @test_options) == 0
    assert compare(%Primed{string: "fff"}, %Primed{string: "xxx"}, @test_options) == 0
    assert compare(%Primed{string: "abc"}, %Primed{string: "xyz"}) == 0
    assert compare(%Primed{string: "123"}, %Primed{string: "456"}) == 0
    assert compare(%Primed{string: "fff"}, %Primed{string: "xxx"}) == 0
  end

  test "returns nil with invalid arguments" do
    assert compare(%Primed{string: "n"}, %Primed{string: "naght"}, @test_options) == nil
    assert compare(%Primed{string: "night"}, %Primed{string: "n"}, @test_options) == nil
    assert compare(%Primed{string: "ni"}, %Primed{string: "naght"}, @adv_test_options) == nil
    assert compare(%Primed{string: "night"}, %Primed{string: "na"}, @adv_test_options) == nil
  end
end
