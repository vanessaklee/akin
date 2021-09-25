defmodule LevenshteinTest do
  use ExUnit.Case
  import Akin.Levenshtein, only: [compare: 2]
  alias Akin.Primed

  test "returns nil with empty arguments" do
    assert compare(%Primed{string: ""}, %Primed{string: ""}) == 1
    assert compare(%Primed{string: "abc"}, %Primed{string: ""}) == 0.0
    assert compare(%Primed{string: ""}, %Primed{string: "xyz"}) == 0.0
  end

  test "return 1 with equal arguments" do
    assert compare(%Primed{string: "a"}, %Primed{string: "a"}) == 1
    assert compare(%Primed{string: "abc"}, %Primed{string: "abc"}) == 1
    assert compare(%Primed{string: "123"}, %Primed{string: "123"}) == 1
  end

  test "return distance with unequal arguments" do
    assert compare(%Primed{string: "abc"}, %Primed{string: "xyz"}) == 0.0
    assert compare(%Primed{string: "123"}, %Primed{string: "456"}) == 0.0
  end

  test "return distance with valid arguments" do
    assert compare(%Primed{string: "sitting"}, %Primed{string: "kitten"}) == 0.57
    assert compare(%Primed{string: "kitten"}, %Primed{string: "sitting"}) == 0.57
    assert compare(%Primed{string: "cake"}, %Primed{string: "drake"}) == 0.6
    assert compare(%Primed{string: "drake"}, %Primed{string: "cake"}) == 0.6
    assert compare(%Primed{string: "saturday"}, %Primed{string: "sunday"}) == 0.63
    assert compare(%Primed{string: "sunday"}, %Primed{string: "saturday"}) == 0.63
    assert compare(%Primed{string: "book"}, %Primed{string: "back"}) == 0.5
    assert compare(%Primed{string: "dog"}, %Primed{string: "fog"}) == 0.67
    assert compare(%Primed{string: "foq"}, %Primed{string: "fog"}) == 0.67
    assert compare(%Primed{string: "fvg"}, %Primed{string: "fog"}) == 0.67
    assert compare(%Primed{string: "encyclopedia"}, %Primed{string: "encyclopediaz"}) == 0.92
    assert compare(%Primed{string: "encyclopediz"}, %Primed{string: "encyclopediaz"}) == 0.92
  end
end
