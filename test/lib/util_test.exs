defmodule UtilTest do
  use ExUnit.Case
  import Akin.Util
  alias Akin.Corpus

  test "Removes punction & whitespace, downcases, and returns a Corpus struct unless nil value sent" do
    assert is_struct(compose("word"))
    assert compose("WORD").string == "word"
    assert compose("Two   WORDS").string == "twowords"
    assert compose("Two   WORDS").string == "twowords"
    assert compose("Two 123  WORDS").chunks == ["two", "123", "words"]
    assert compose("Łępicki").string == "łepicki"
    assert compose("") == %Corpus{chunks: [], set: MapSet.new(), stems: [], string: "", original: ""}
    assert compose(nil) == nil
  end

  test "Removes punction & whitespace, downcases, and returns a Corpus struct for two values unless nil value sent" do
    [a, b, c] = list = ["mORe123", "WORDS", "Łepicki"]
      |> Enum.map(fn x -> String.downcase(x) end)
    [left, right] = compose("word", Enum.join(list, " "))

    assert is_struct(left)
    assert right.string == Enum.join(list)
    assert right.chunks == [a, b, c]
    assert right.stems == [Stemmer.stem(a), Stemmer.stem(b), Stemmer.stem("łepicki")]
    assert compose(nil, nil) == nil
  end

  test "Can determine if a string is alphabetic" do
    refute is_alphabetic?("Jason5")
    assert is_alphabetic?("Jason")
    refute is_alphabetic?("")
    refute is_alphabetic?(nil)
  end

  test "Removes duplicates from a string (except for c)" do
    assert deduplicate("") == ""
    assert deduplicate("mississippi") == "misisipi"
    assert deduplicate("accross") == "accros"
    assert deduplicate(["ssaammee"]) == ["ssaammee"]
    assert deduplicate(nil) == nil
  end

  test "Intersection of two lists is returned" do
    assert intersect("abc", "adbecf") == ["a", "b", "c"]
    assert intersect("context", "contentcontent") == ["c", "o", "n", "t", "e", "t"]
    assert modulize([:a]) == [:a]
    assert modulize(nil) == nil
  end

  test "Input is camelized and returned as an  atom" do
    assert modulize(["a", "b"]) == [Akin.A, Akin.B]
    assert modulize("a") == Akin.A
    assert modulize(:a) == :a
    assert modulize(nil) == nil
  end

  test "Tokenizes the input into N-grams" do
    str = "abcdefg"
    assert  Enum.all?(ngram_tokenize(str, 2), fn x -> String.length(x) == 2 end)
    assert  Enum.all?(ngram_tokenize(str, 3), fn x -> String.length(x) == 3 end)
    assert  Enum.all?(ngram_tokenize(str, 5), fn x -> String.length(x) == 5 end)
    assert ngram_tokenize(123) == []
    assert ngram_tokenize(nil) == []
  end

  describe "The ngram_size is returned correctly" do
    setup do
      %{default: Keyword.get(Akin.default_opts(), :ngram_size)}
    end

    test "The n_gram size is correct when option list contains an ngram_size value", cxt do
      assert ngram_size(Akin.default_opts()) == cxt.default
      assert ngram_size([ngram_size: 3]) == 3
    end

    test "The n_gram size is default size when not present", cxt do
      assert ngram_size(nil) == cxt.default
      assert ngram_size([not_ngram_size: 3]) == cxt.default
      assert ngram_size([]) == cxt.default
    end
  end

  describe "The length_cutoff is returned correctly" do
    setup do
      %{default: Keyword.get(Akin.default_opts(), :length_cutoff)}
    end

    test "The length_cutoff size is correct when option list contains an length_cutoff value", cxt do
      assert length_cutoff(Akin.default_opts()) == cxt.default
      assert length_cutoff([length_cutoff: 10]) == 10
    end

    test "The length_cutoff size is default size when not present", cxt do
      assert length_cutoff(nil) == cxt.default
      assert length_cutoff([not_length_cutoff: 3]) == cxt.default
      assert length_cutoff([]) == cxt.default
    end
  end

  describe "The match_level is returned correctly" do
    setup do
      %{default: Keyword.get(Akin.default_opts(), :match_level)}
    end

    test "The match_level size is correct when option list contains an match_level value", cxt do
      assert match_level(Akin.default_opts()) == cxt.default
      assert match_level([match_level: 10]) == 10
    end

    test "The match_level size is default size when not present", cxt do
      assert match_level(nil) == cxt.default
      assert match_level([not_match_level: 3]) == cxt.default
      assert match_level([]) == cxt.default
    end
  end

  describe "The match_cutoff is returned correctly" do
    setup do
      %{default: Keyword.get(Akin.default_opts(), :match_cutoff)}
    end

    test "The match_cutoff size is correct when option list contains an match_cutoff value", cxt do
      assert match_cutoff(Akin.default_opts()) == cxt.default
      assert match_cutoff([match_cutoff: 10]) == 10
    end

    test "The match_level size is default size when not present", cxt do
      assert match_cutoff(nil) == cxt.default
      assert match_cutoff([not_match_cutoff: 3]) == cxt.default
      assert match_cutoff([]) == cxt.default
    end
  end

  describe "The boost_initials is returned correctly" do
    test "The boost_initials size is correct when option list contains an boost_initials value" do
      assert boost_initials?([]) == false
      assert boost_initials?([boost_initials: true]) == true
    end
  end
end
