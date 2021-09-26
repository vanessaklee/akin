defmodule MetaphoneTest do
  use ExUnit.Case
  import Akin.Metaphone, only: [compare: 2]
  alias Akin.Corpus

  test "returns nil with empty argument" do
    assert compare(%Corpus{string: ""}, %Corpus{string: ""}) == nil
    assert compare(%Corpus{string: "abc"}, %Corpus{string: ""}) == nil
    assert compare(%Corpus{string: ""}, %Corpus{string: "xyz"}) == nil
  end

  test "returns nil with non-phonetic arguments" do
    assert compare(%Corpus{string: "123"}, %Corpus{string: "123"}) == nil
    assert compare(%Corpus{string: "123"}, %Corpus{string: ""}) == nil
    assert compare(%Corpus{string: ""}, %Corpus{string: "123"}) == nil
  end

  test "returns true with phonetically similar arguments" do
    assert compare(%Corpus{string: "dumb"}, %Corpus{string: "dum"}) == 1
    assert compare(%Corpus{string: "smith"}, %Corpus{string: "smeth"}) == 1
    assert compare(%Corpus{string: "merci"}, %Corpus{string: "mercy"}) == 1
  end

  test "returns false with phonetically dissimilar arguments" do
    assert compare(%Corpus{string: "dumb"}, %Corpus{string: "gum"}) == 0
    assert compare(%Corpus{string: "smith"}, %Corpus{string: "kiss"}) == 0
    assert compare(%Corpus{string: "merci"}, %Corpus{string: "burpy"}) == 0
  end
end
