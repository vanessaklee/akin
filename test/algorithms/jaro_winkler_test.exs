defmodule JaroWinklerTest do
  use ExUnit.Case
  import Akin.JaroWinkler, only: [compare: 2]
  alias Akin.Primed

  test "returns nil with empty arguments" do
    assert compare(%Primed{string: ""}, %Primed{string: ""}) == nil
    assert compare(%Primed{string: "abc"}, %Primed{string: ""}) == nil
    assert compare(%Primed{string: ""}, %Primed{string: "xyz"}) == nil
  end

  test "return 1 with equal arguments" do
    assert compare(%Primed{string: "a"}, %Primed{string: "a"}) == 1
    assert compare(%Primed{string: "abc"}, %Primed{string: "abc"}) == 1
    assert compare(%Primed{string: "123"}, %Primed{string: "123"}) == 1
  end

  test "return 0 with unequal arguments" do
    assert compare(%Primed{string: "abc"}, %Primed{string: "xys"}) == 0
    assert compare(%Primed{string: "123"}, %Primed{string: "456"}) == 0
  end

  test "return distance with valid arguments" do
    assert compare(%Primed{string: "aa"}, %Primed{string: "a"}) == 0.8500000000000001
    assert compare(%Primed{string: "a"}, %Primed{string: "aa"}) == 0.8500000000000001
    assert compare(%Primed{string: "veryveryverylong"}, %Primed{string: "v"}) == 0.71875
    assert compare(%Primed{string: "v"}, %Primed{string: "veryveryverylong"}) == 0.71875
    assert compare(%Primed{string: "martha"}, %Primed{string: "marhta"}) == 0.9611111111111111
    assert compare(%Primed{string: "dwayne"}, %Primed{string: "duane"}) == 0.8400000000000001
    assert compare(%Primed{string: "dixon"}, %Primed{string: "dicksonx"}) == 0.8133333333333332
    assert compare(%Primed{string: "abcvwxyz"}, %Primed{string: "cabvwxyz"}) == 0.9583333333333334
    assert compare(%Primed{string: "jones"}, %Primed{string: "johnson"}) == 0.8323809523809523
    assert compare(%Primed{string: "henka"}, %Primed{string: "henkan"}) == 0.9666666666666667
    assert compare(%Primed{string: "fvie"}, %Primed{string: "ten"}) == 0

    assert compare(%Primed{string: "zac ephron"}, %Primed{string: "zac efron"}) > compare(%Primed{string: "zac ephron"}, %Primed{string: "kai ephron"})

    assert compare(%Primed{string: "brittney spears"}, %Primed{string: "britney spears"}) >
             compare(%Primed{string: "brittney spears"}, %Primed{string: "brittney startzman"})
  end
end
