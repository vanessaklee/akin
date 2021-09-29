defmodule SorensenDiceTest do
  use ExUnit.Case
  import Akin.SorensenDice, only: [compare: 2, compare: 3]
  import Akin.Util, only: [compose: 1]

  test "returns nil with empty arguments" do
    assert compare(compose(""), compose(""), ngram_size: 1) == 0.0
    assert compare(compose("abc"), compose(""), ngram_size: 1) == 0.0
    assert compare(compose(""), compose("xyz"), ngram_size: 1) == 0.0
    assert compare(compose(""), compose("")) == 0.0
    assert compare(compose("abc"), compose("")) == 0.0
    assert compare(compose(""), compose("xyz")) == 0
  end

  test "return 1.0 with equal arguments" do
    assert compare(compose("a"), compose("a"), ngram_size: 1) == 1.0
    assert compare(compose("abc"), compose("abc"), ngram_size: 2) == 1.0
    assert compare(compose("123"), compose("123"), ngram_size: 3) == 1.0
    assert compare(compose("abc"), compose("abc")) == 1.0
    assert compare(compose("123"), compose("123")) == 1
  end

  test "return 0.0 with unequal arguments" do
    assert compare(compose("abc"), compose("xyz"), ngram_size: 1) == 0.0
    assert compare(compose("123"), compose("456"), ngram_size: 2) == 0.0
    assert compare(compose("fff"), compose("xxx"), ngram_size: 3) == 0.0
    assert compare(compose("abc"), compose("xyz")) == 0.0
    assert compare(compose("123"), compose("456")) == 0.0
    assert compare(compose("fff"), compose("xxx")) == 0
  end

  test "returns nil with invalid arguments" do
    assert compare(compose("n"), compose("naght")) == 0.0
    assert compare(compose("night"), compose("n")) == 0.0
    assert compare(compose("n"), compose("naght"), ngram_size: 2) == 0.0
    assert compare(compose("night"), compose("n"), ngram_size: 2) == 0.0
    assert compare(compose("ni"), compose("naght"), ngram_size: 3) == 0.0
    assert compare(compose("night"), compose("na"), ngram_size: 3) == 0
  end

  test "return distance with valid arguments" do
    assert compare(compose("night"), compose("nacht"), ngram_size: 1) == 0.6
    assert compare(compose("night"), compose("naght"), ngram_size: 1) == 0.8

    assert compare(compose("context"), compose("contact"), ngram_size: 1) ==
             0.7142857142857143
    assert compare(compose("weird"), compose("wierd"), []) == 0.25
    assert compare(compose("weird"), compose("wierd"), [ngram_size: 1]) == 0.8
    assert compare(compose("night"), compose("nacht"), ngram_size: 2) == 0.25
    assert compare(compose("night"), compose("naght"), ngram_size: 2) == 0.5
    assert compare(compose("context"), compose("contact"), ngram_size: 2) == 0.5

    assert compare(compose("contextcontext"), compose("contact"), ngram_size: 2) ==
             0.3157894736842105

    assert compare(compose("context"), compose("contactcontact"), ngram_size: 2) ==
             0.3157894736842105

    assert compare(compose("ht"), compose("nacht"), ngram_size: 2) == 0.4
    assert compare(compose("xp"), compose("nacht"), ngram_size: 2) == 0

    assert compare(compose("ht"), compose("hththt"), ngram_size: 2) ==
             0.3333333333333333

    assert compare(compose("night"), compose("nacht")) == 0.25
    assert compare(compose("night"), compose("naght")) == 0.5
    assert compare(compose("context"), compose("contact")) == 0.5

    assert compare(compose("contextcontext"), compose("contact")) ==
             0.3157894736842105

    assert compare(compose("context"), compose("contactcontact")) ==
             0.3157894736842105

    assert compare(compose("ht"), compose("nacht")) == 0.4
    assert compare(compose("xp"), compose("nacht")) == 0.0
    assert compare(compose("ht"), compose("hththt")) == 0.3333333333333333

    assert compare(compose("night"), compose("nacht"), ngram_size: 3) == 0

    assert compare(compose("night"), compose("naght"), ngram_size: 3) ==
             0.3333333333333333

    assert compare(compose("context"), compose("contact"), ngram_size: 3) == 0.4
  end
end
