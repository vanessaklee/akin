defmodule UtilTest do
  use ExUnit.Case
  import Akin.Util
  alias Akin.Corpus

  test "Removes punction & whitespace, downcases, and returns a Corpus struct unless nil value sent" do
    assert is_struct(compose("word"))
    assert compose("WORD").string == "word"
    assert compose("Two   WORDS").string == "twowords"
    assert compose("Two   WORDS").string == "twowords"
    assert compose("Two 123  WORDS").list == ["two", "123", "words"]
    assert compose("Łępicki").string == "łepicki"
    assert compose("") == %Corpus{list: [], set: MapSet.new(), stems: [], string: "", original: ""}
    assert compose(nil) == nil
  end

  test "Removes punction & whitespace, downcases, and returns a Corpus struct for two values unless nil value sent" do
    [a, b, c] = list = ["mORe123", "WORDS", "Łepicki"]
      |> Enum.map(fn x -> String.downcase(x) end)
    [left, right] = compose("word", Enum.join(list, " "))

    assert is_struct(left)
    assert right.string == Enum.join(list)
    assert right.list == [a, b, c]
    assert right.stems == [Stemmer.stem(a), Stemmer.stem(b), Stemmer.stem("łepicki")]
    assert compose(nil, nil) == []
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
      assert opts(Akin.default_opts(), :ngram_size) == cxt.default
      assert opts([ngram_size: 3], :ngram_size) == 3
    end

    test "The n_gram size is default size when not present", cxt do
      assert opts(nil, :ngram_size) == cxt.default
      assert opts([not_ngram_size: 3], :ngram_size) == cxt.default
      assert opts([], :ngram_size) == cxt.default
    end
  end

  describe "The short_length is returned correctly" do
    setup do
      %{default: Keyword.get(Akin.default_opts(), :short_length)}
    end

    test "The short_length size is correct when option list contains an short_length value", cxt do
      assert opts(Akin.default_opts(), :short_length) == cxt.default
      assert opts([short_length: 10], :short_length) == 10
    end

    test "The short_length size is default size when not present", cxt do
      assert opts(nil, :short_length) == cxt.default
      assert opts(nil, nil) == nil
      assert opts([not_short_length: 3], :short_length) == cxt.default
      assert opts([], :short_length) == cxt.default
    end
  end

  describe "The level is returned correctly" do
    setup do
      %{default: Keyword.get(Akin.default_opts(), :level)}
    end

    test "The level size is correct when option list contains an level value", cxt do
      assert opts(Akin.default_opts(), :level) == cxt.default
      assert opts([level: 10], :level) == 10
    end

    test "The level size is default size when not present", cxt do
      assert opts(nil, :level) == cxt.default
      assert opts([not_level: 3], :level) == cxt.default
      assert opts([], :level) == cxt.default
    end
  end

  describe "The match_at is returned correctly" do
    setup do
      %{default: Keyword.get(Akin.default_opts(), :match_at)}
    end

    test "The match_at size is correct when option list contains an match_at value", cxt do
      assert opts(Akin.default_opts(), :match_at) == cxt.default
      assert opts([match_at: 10], :match_at) == 10
    end

    test "The level size is default size when not present", cxt do
      assert opts(nil, :match_at) == cxt.default
      assert opts([not_match_at: 3], :match_at) == cxt.default
      assert opts([], :match_at) == cxt.default
    end
  end
end
