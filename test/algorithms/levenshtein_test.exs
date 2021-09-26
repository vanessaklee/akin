defmodule LevenshteinTest do
  use ExUnit.Case
  import Akin.Levenshtein, only: [compare: 3]
  alias Akin.Corpus

  test "returns nil with empty arguments" do
    assert compare(%Corpus{string: ""}, %Corpus{string: ""}, []) == 1
    assert compare(%Corpus{string: "abc"}, %Corpus{string: ""}, []) == 0.0
    assert compare(%Corpus{string: ""}, %Corpus{string: "xyz"}, []) == 0.0
  end

  test "return 1 with equal arguments" do
    assert compare(%Corpus{string: "a"}, %Corpus{string: "a"}, []) == 1
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "abc"}, []) == 1
    assert compare(%Corpus{string: "123"}, %Corpus{string: "123"}, []) == 1
  end

  test "return distance with unequal arguments" do
    assert compare(%Corpus{string: "abc"}, %Corpus{string: "xyz"}, []) == 0.0
    assert compare(%Corpus{string: "123"}, %Corpus{string: "456"}, []) == 0.0
  end

  test "return distance with valid arguments" do
    assert compare(%Corpus{string: "sitting"}, %Corpus{string: "kitten"}, []) |> Float.round(2) ==
             0.57

    assert compare(%Corpus{string: "kitten"}, %Corpus{string: "sitting"}, []) |> Float.round(2) ==
             0.57

    assert compare(%Corpus{string: "cake"}, %Corpus{string: "drake"}, []) |> Float.round(2) == 0.6
    assert compare(%Corpus{string: "drake"}, %Corpus{string: "cake"}, []) |> Float.round(2) == 0.6

    assert compare(%Corpus{string: "saturday"}, %Corpus{string: "sunday"}, []) |> Float.round(2) ==
             0.63

    assert compare(%Corpus{string: "sunday"}, %Corpus{string: "saturday"}, []) |> Float.round(2) ==
             0.63

    assert compare(%Corpus{string: "book"}, %Corpus{string: "back"}, []) |> Float.round(2) == 0.5
    assert compare(%Corpus{string: "dog"}, %Corpus{string: "fog"}, []) |> Float.round(2) == 0.67
    assert compare(%Corpus{string: "foq"}, %Corpus{string: "fog"}, []) |> Float.round(2) == 0.67
    assert compare(%Corpus{string: "fvg"}, %Corpus{string: "fog"}, []) |> Float.round(2) == 0.67

    assert compare(%Corpus{string: "encyclopedia"}, %Corpus{string: "encyclopediaz"}, [])
           |> Float.round(2) == 0.92

    assert compare(%Corpus{string: "encyclopediz"}, %Corpus{string: "encyclopediaz"}, [])
           |> Float.round(2) == 0.92
  end
end
