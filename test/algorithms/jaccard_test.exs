defmodule JaccardTest do
  use ExUnit.Case
  import Akin.Jaccard, only: [compare: 2, compare: 3]
  alias Akin.Primed

  test "returns nil with empty arguments" do
    assert compare(%Primed{string: ""}, %Primed{string: ""}, 1) == nil
    assert compare(%Primed{string: "abc"}, %Primed{string: ""}, 1) == nil
    assert compare(%Primed{string: ""}, %Primed{string: "xyz"}, 1) == nil
    assert compare(%Primed{string: ""}, %Primed{string: ""}) == nil
    assert compare(%Primed{string: "abc"}, %Primed{string: ""}) == nil
    assert compare(%Primed{string: ""}, %Primed{string: "xyz"}) == nil
  end

  test "return 1 with equal arguments" do
    assert compare(%Primed{string: "a"}, %Primed{string: "a"}, 1) == 1
    assert compare(%Primed{string: "abc"}, %Primed{string: "abc"}, 2) == 1
    assert compare(%Primed{string: "123"}, %Primed{string: "123"}, 3) == 1
    assert compare(%Primed{string: "abc"}, %Primed{string: "abc"}) == 1
    assert compare(%Primed{string: "123"}, %Primed{string: "123"}) == 1
  end

  test "return 0 with unequal arguments" do
    assert compare(%Primed{string: "abc"}, %Primed{string: "xyz"}, 1) == 0
    assert compare(%Primed{string: "123"}, %Primed{string: "456"}, 2) == 0
    assert compare(%Primed{string: "fff"}, %Primed{string: "xxx"}, 3) == 0
    assert compare(%Primed{string: "abc"}, %Primed{string: "xyz"}) == 0
    assert compare(%Primed{string: "123"}, %Primed{string: "456"}) == 0
    assert compare(%Primed{string: "fff"}, %Primed{string: "xxx"}) == 0
  end

  test "returns nil with invalid arguments" do
    assert compare(%Primed{string: "n"}, %Primed{string: "naght"}) == nil
    assert compare(%Primed{string: "night"}, %Primed{string: "n"}) == nil
    assert compare(%Primed{string: "n"}, %Primed{string: "naght"}, 2) == nil
    assert compare(%Primed{string: "night"}, %Primed{string: "n"}, 2) == nil
    assert compare(%Primed{string: "ni"}, %Primed{string: "naght"}, 3) == nil
    assert compare(%Primed{string: "night"}, %Primed{string: "na"}, 3) == nil
  end

  test "return distance with valid arguments" do
    assert compare(%Primed{string: "night"}, %Primed{string: "nacht"}, 1) == 0.42857142857142855
    assert compare(%Primed{string: "night"}, %Primed{string: "naght"}, 1) == 0.6666666666666666
    assert compare(%Primed{string: "context"}, %Primed{string: "contact"}, 1) == 0.5555555555555556

    assert compare(%Primed{string: "night"}, %Primed{string: "nacht"}, 2) == 0.14285714285714285
    assert compare(%Primed{string: "night"}, %Primed{string: "naght"}, 2) == 0.3333333333333333
    assert compare(%Primed{string: "context"}, %Primed{string: "contact"}, 2) == 0.3333333333333333
    assert compare(%Primed{string: "contextcontext"}, %Primed{string: "contact"}, 2) == 0.1875
    assert compare(%Primed{string: "context"}, %Primed{string: "contactcontact"}, 2) == 0.1875
    assert compare(%Primed{string: "ht"}, %Primed{string: "nacht"}, 2) == 0.25
    assert compare(%Primed{string: "xp"}, %Primed{string: "nacht"}, 2) == 0
    assert compare(%Primed{string: "ht"}, %Primed{string: "hththt"}, 2) == 0.2

    assert compare(%Primed{string: "night"}, %Primed{string: "nacht"}, 3) == 0
    assert compare(%Primed{string: "night"}, %Primed{string: "naght"}, 3) == 0.2
    assert compare(%Primed{string: "context"}, %Primed{string: "contact"}, 3) == 0.25
  end
end
