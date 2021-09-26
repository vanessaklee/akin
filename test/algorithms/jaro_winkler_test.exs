defmodule JaroWinklerTest do
  use ExUnit.Case
  import Akin.JaroWinkler, only: [compare: 2]
  alias Akin.Corpus

  test "returns nil with empty arguments" do
    assert compare(%Corpus{string: ""}, %Corpus{string: ""}) == 0.0
    assert compare(%Corpus{string: "abc"}, %Corpus{string: ""}) == 0.0
    assert compare(%Corpus{string: ""}, %Corpus{string: "xyz"}) == 0.0
  end

  test "return 1 with equal arguments" do
    assert compare(%Corpus{string: "a"}, %Corpus{string: "a"}) == 1
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "abc"}) == 1
    assert compare(%Corpus{string: "123"}, %Corpus{string: "123"}) == 1
  end

  test "return 0 with unequal arguments" do
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "xys"}) == 0
    assert compare(%Corpus{string: "123"}, %Corpus{string: "456"}) == 0
  end

  test "return distance with valid arguments" do
    assert compare(%Corpus{string: "aa"}, %Corpus{string: "a"}) == 0.8500000000000001
    assert compare(%Corpus{string: "a"}, %Corpus{string: "aa"}) == 0.8500000000000001
    assert compare(%Corpus{string: "veryveryverylong"}, %Corpus{string: "v"}) == 0.71875
    assert compare(%Corpus{string: "v"}, %Corpus{string: "veryveryverylong"}) == 0.71875
    assert compare(%Corpus{string: "martha"}, %Corpus{string: "marhta"}) == 0.9611111111111111
    assert compare(%Corpus{string: "dwayne"}, %Corpus{string: "duane"}) == 0.8400000000000001
    assert compare(%Corpus{string: "dixon"}, %Corpus{string: "dicksonx"}) == 0.8133333333333332
    assert compare(%Corpus{string: "abcvwxyz"}, %Corpus{string: "cabvwxyz"}) == 0.9583333333333334
    assert compare(%Corpus{string: "jones"}, %Corpus{string: "johnson"}) == 0.8323809523809523
    assert compare(%Corpus{string: "henka"}, %Corpus{string: "henkan"}) == 0.9666666666666667
    assert compare(%Corpus{string: "fvie"}, %Corpus{string: "ten"}) == 0

    assert compare(%Corpus{string: "zac ephron"}, %Corpus{string: "zac efron"}) >
             compare(%Corpus{string: "zac ephron"}, %Corpus{string: "kai ephron"})

    assert compare(%Corpus{string: "brittney spears"}, %Corpus{string: "britney spears"}) >
             compare(%Corpus{string: "brittney spears"}, %Corpus{string: "brittney startzman"})
  end
end
