defmodule NgramTest do
  use ExUnit.Case
  import Akin.Ngram, only: [compare: 3]
  alias Akin.Corpus

  test "return None with empty arguments" do
    assert compare(%Corpus{string: ""}, %Corpus{string: ""}, 1) == nil
    assert compare(%Corpus{string: "abc"}, %Corpus{string: ""}, 1) == nil
    assert compare(%Corpus{string: ""}, %Corpus{string: "xyz"}, 1) == nil
  end

  test "return 1 with equal arguments" do
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "abc"}, 1) == 1
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "abc"}, 2) == 1
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "abc"}, 3) == 1
  end

  test "return 0 with unequal arguments" do
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "xyz"}, 1) == 0
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "xyz"}, 2) == 0
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "xyz"}, 3) == 0
  end

  test "return None with invalid arguments" do
    assert compare(%Corpus{string: "n"}, %Corpus{string: "naght"}, 2) == nil
    assert compare(%Corpus{string: "night"}, %Corpus{string: "n"}, 2) == nil
    assert compare(%Corpus{string: "ni"}, %Corpus{string: "naght"}, 3) == nil
    assert compare(%Corpus{string: "night"}, %Corpus{string: "na"}, 3) == nil
  end

  test "return distance with valid arguments" do
    assert compare(%Corpus{string: "night"}, %Corpus{string: "nacht"}, 1) == 0.6
    assert compare(%Corpus{string: "night"}, %Corpus{string: "naght"}, 1) == 0.8

    assert compare(%Corpus{string: "context"}, %Corpus{string: "contact"}, 1) ==
             0.7142857142857143

    assert compare(%Corpus{string: "night"}, %Corpus{string: "nacht"}, 2) == 0.25
    assert compare(%Corpus{string: "night"}, %Corpus{string: "naght"}, 2) == 0.5
    assert compare(%Corpus{string: "context"}, %Corpus{string: "contact"}, 2) == 0.5

    assert compare(%Corpus{string: "contextcontext"}, %Corpus{string: "contact"}, 2) ==
             0.23076923076923078

    assert compare(%Corpus{string: "context"}, %Corpus{string: "contactcontact"}, 2) ==
             0.23076923076923078

    assert compare(%Corpus{string: "ht"}, %Corpus{string: "nacht"}, 2) == 0.25
    assert compare(%Corpus{string: "xp"}, %Corpus{string: "nacht"}, 2) == 0
    assert compare(%Corpus{string: "ht"}, %Corpus{string: "hththt"}, 2) == 0.2

    assert compare(%Corpus{string: "night"}, %Corpus{string: "nacht"}, 3) == 0
    assert compare(%Corpus{string: "night"}, %Corpus{string: "naght"}, 3) == 0.3333333333333333
    assert compare(%Corpus{string: "context"}, %Corpus{string: "contact"}, 3) == 0.4
  end
end
