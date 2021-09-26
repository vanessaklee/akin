defmodule DiceSorensenTest do
  use ExUnit.Case
  import Akin.DiceSorensen, only: [compare: 2, compare: 3]
  alias Akin.Corpus

  test "returns nil with empty arguments" do
    assert compare(%Corpus{string: ""}, %Corpus{string: ""}, ngram_size: 1) == 0
    assert compare(%Corpus{string: "abc"}, %Corpus{string: ""}, ngram_size: 1) == 0
    assert compare(%Corpus{string: ""}, %Corpus{string: "xyz"}, ngram_size: 1) == 0
    assert compare(%Corpus{string: ""}, %Corpus{string: ""}) == 0
    assert compare(%Corpus{string: "abc"}, %Corpus{string: ""}) == 0
    assert compare(%Corpus{string: ""}, %Corpus{string: "xyz"}) == 0
  end

  test "return 1 with equal arguments" do
    assert compare(%Corpus{string: "a"}, %Corpus{string: "a"}, ngram_size: 1) == 1
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "abc"}, ngram_size: 2) == 1
    assert compare(%Corpus{string: "123"}, %Corpus{string: "123"}, ngram_size: 3) == 1
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "abc"}) == 1
    assert compare(%Corpus{string: "123"}, %Corpus{string: "123"}) == 1
  end

  test "return 0 with unequal arguments" do
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "xyz"}, ngram_size: 1) == 0
    assert compare(%Corpus{string: "123"}, %Corpus{string: "456"}, ngram_size: 2) == 0
    assert compare(%Corpus{string: "fff"}, %Corpus{string: "xxx"}, ngram_size: 3) == 0
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "xyz"}) == 0
    assert compare(%Corpus{string: "123"}, %Corpus{string: "456"}) == 0
    assert compare(%Corpus{string: "fff"}, %Corpus{string: "xxx"}) == 0
  end

  test "returns nil with invalid arguments" do
    assert compare(%Corpus{string: "n"}, %Corpus{string: "naght"}) == 0
    assert compare(%Corpus{string: "night"}, %Corpus{string: "n"}) == 0
    assert compare(%Corpus{string: "n"}, %Corpus{string: "naght"}, ngram_size: 2) == 0
    assert compare(%Corpus{string: "night"}, %Corpus{string: "n"}, ngram_size: 2) == 0
    assert compare(%Corpus{string: "ni"}, %Corpus{string: "naght"}, ngram_size: 3) == 0
    assert compare(%Corpus{string: "night"}, %Corpus{string: "na"}, ngram_size: 3) == 0
  end

  test "return distance with valid arguments" do
    assert compare(%Corpus{string: "night"}, %Corpus{string: "nacht"}, ngram_size: 1) == 0.6
    assert compare(%Corpus{string: "night"}, %Corpus{string: "naght"}, ngram_size: 1) == 0.8

    assert compare(%Corpus{string: "context"}, %Corpus{string: "contact"}, ngram_size: 1) ==
             0.7142857142857143

    assert compare(%Corpus{string: "night"}, %Corpus{string: "nacht"}, ngram_size: 2) == 0.25
    assert compare(%Corpus{string: "night"}, %Corpus{string: "naght"}, ngram_size: 2) == 0.5
    assert compare(%Corpus{string: "context"}, %Corpus{string: "contact"}, ngram_size: 2) == 0.5

    assert compare(%Corpus{string: "contextcontext"}, %Corpus{string: "contact"}, ngram_size: 2) ==
             0.3157894736842105

    assert compare(%Corpus{string: "context"}, %Corpus{string: "contactcontact"}, ngram_size: 2) ==
             0.3157894736842105

    assert compare(%Corpus{string: "ht"}, %Corpus{string: "nacht"}, ngram_size: 2) == 0.4
    assert compare(%Corpus{string: "xp"}, %Corpus{string: "nacht"}, ngram_size: 2) == 0

    assert compare(%Corpus{string: "ht"}, %Corpus{string: "hththt"}, ngram_size: 2) ==
             0.3333333333333333

    assert compare(%Corpus{string: "night"}, %Corpus{string: "nacht"}) == 0.25
    assert compare(%Corpus{string: "night"}, %Corpus{string: "naght"}) == 0.5
    assert compare(%Corpus{string: "context"}, %Corpus{string: "contact"}) == 0.5

    assert compare(%Corpus{string: "contextcontext"}, %Corpus{string: "contact"}) ==
             0.3157894736842105

    assert compare(%Corpus{string: "context"}, %Corpus{string: "contactcontact"}) ==
             0.3157894736842105

    assert compare(%Corpus{string: "ht"}, %Corpus{string: "nacht"}) == 0.4
    assert compare(%Corpus{string: "xp"}, %Corpus{string: "nacht"}) == 0
    assert compare(%Corpus{string: "ht"}, %Corpus{string: "hththt"}) == 0.3333333333333333

    assert compare(%Corpus{string: "night"}, %Corpus{string: "nacht"}, ngram_size: 3) == 0

    assert compare(%Corpus{string: "night"}, %Corpus{string: "naght"}, ngram_size: 3) ==
             0.3333333333333333

    assert compare(%Corpus{string: "context"}, %Corpus{string: "contact"}, ngram_size: 3) == 0.4
  end
end
