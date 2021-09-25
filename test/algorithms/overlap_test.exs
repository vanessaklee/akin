defmodule OverlapTest do
  use ExUnit.Case
  import Akin.Overlap, only: [compare: 3]
  alias Akin.Primed

  test "returns nil with empty arguments" do
    assert compare(%Primed{string: "n"}, %Primed{string: "naght"}, 2) == nil
    assert compare(%Primed{string: "night"}, %Primed{string: "n"}, 2) == nil
    assert compare(%Primed{string: "ni"}, %Primed{string: "naght"}, 3) == nil
    assert compare(%Primed{string: "night"}, %Primed{string: "na"}, 3) == nil
  end

  test "returns nil with invalid arguments" do
    assert compare(%Primed{string: ""}, %Primed{string: ""}, 1) == nil
    assert compare(%Primed{string: "abc"}, %Primed{string: ""}, 1) == nil
    assert compare(%Primed{string: ""}, %Primed{string: "abc"}, 1) == nil
  end

  test "returns 1 with equal arguments" do
    assert compare(%Primed{string: "abc"}, %Primed{string: "abc"}, 1) == 1
    assert compare(%Primed{string: "abc"}, %Primed{string: "abc"}, 2) == 1
    assert compare(%Primed{string: "abc"}, %Primed{string: "abc"}, 3) == 1
  end

  test "returns 0 with unequal arguments" do
    assert compare(%Primed{string: "abc"}, %Primed{string: "xyz"}, 1) == 0
    assert compare(%Primed{string: "abc"}, %Primed{string: "xyz"}, 2) == 0
    assert compare(%Primed{string: "abc"}, %Primed{string: "xyz"}, 3) == 0
  end

  test "return distance with valid arguments" do
    assert compare(%Primed{string: "bob"}, %Primed{string: "bobman"}, 1) == 1
    assert compare(%Primed{string: "bob"}, %Primed{string: "manbobman"}, 1) == 1
    assert compare(%Primed{string: "night"}, %Primed{string: "nacht"}, 1) == 0.6
    assert compare(%Primed{string: "night"}, %Primed{string: "naght"}, 1) == 0.8
    assert compare(%Primed{string: "context"}, %Primed{string: "contact"}, 1) == 0.7142857142857143
    assert compare(%Primed{string: "night"}, %Primed{string: "nacht"}, 2) == 0.25
    assert compare(%Primed{string: "night"}, %Primed{string: "naght"}, 2) == 0.5
    assert compare(%Primed{string: "context"}, %Primed{string: "contact"}, 2) == 0.5
    assert compare(%Primed{string: "contextcontext"}, %Primed{string: "contact"}, 2) == 0.5
    assert compare(%Primed{string: "context"}, %Primed{string: "contactcontact"}, 2) == 0.5
    assert compare(%Primed{string: "ht"}, %Primed{string: "nacht"}, 2) == 1
    assert compare(%Primed{string: "xp"}, %Primed{string: "nacht"}, 2) == 0
    assert compare(%Primed{string: "ht"}, %Primed{string: "hththt"}, 2) == 1
    assert compare(%Primed{string: "night"}, %Primed{string: "nacht"}, 3) == 0
    assert compare(%Primed{string: "night"}, %Primed{string: "naght"}, 3) == 0.3333333333333333
    assert compare(%Primed{string: "context"}, %Primed{string: "contact"}, 3) == 0.4
  end
end
