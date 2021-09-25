defmodule MetaphoneTest do
  use ExUnit.Case
  import Akin.Metaphone, only: [compare: 2]
  alias Akin.Primed

  test "returns nil with empty argument" do
    assert compare(%Primed{string: ""}, %Primed{string: ""}) == nil
    assert compare(%Primed{string: "abc"}, %Primed{string: ""}) == nil
    assert compare(%Primed{string: ""}, %Primed{string: "xyz"}) == nil
  end

  test "returns nil with non-phonetic arguments" do
    assert compare(%Primed{string: "123"}, %Primed{string: "123"}) == nil
    assert compare(%Primed{string: "123"}, %Primed{string: ""}) == nil
    assert compare(%Primed{string: ""}, %Primed{string: "123"}) == nil
  end

  test "returns true with phonetically similar arguments" do
    assert compare(%Primed{string: "dumb"}, %Primed{string: "dum"}) == 1
    assert compare(%Primed{string: "smith"}, %Primed{string: "smeth"}) == 1
    assert compare(%Primed{string: "merci"}, %Primed{string: "mercy"}) == 1
  end

  test "returns false with phonetically dissimilar arguments" do
    assert compare(%Primed{string: "dumb"}, %Primed{string: "gum"}) == 0
    assert compare(%Primed{string: "smith"}, %Primed{string: "kiss"}) == 0
    assert compare(%Primed{string: "merci"}, %Primed{string: "burpy"}) == 0
  end
end
