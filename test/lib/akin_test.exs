defmodule AkinTest do
  use ExUnit.Case
  import Akin

  test "comparing two exact strings returns all 1.0 values" do
    results = compare("Alice", "Alice")

    assert Enum.all?(results, fn {_k, v} -> v == 1.0 end)
  end

  test "comparing a name against a list of names in which that name appears, returns a match" do
    assert match_names("alice", ["alice"]) == ["alice"]
  end

  test "comparing a name with inials against a list of names in which a name matching those initials, gets a boost" do
    result_without = match_names("a liddell", ["alice liddell"])
    opts = Keyword.put(Akin.default_opts(), :boost_initials, true)
    results_with = match_names("a liddell", ["alice liddell"], opts)

    assert result_without == []
    assert results_with == ["alice liddell"]
  end

  test "comparing a name with initials matches names with all of those initials match" do
    opts = Keyword.put(Akin.default_opts(), :boost_initials, true)
    names_to_match = ["a liddell", "alice liddel", "alice p liddell", "a pleasance liddell", "ap liddell", "alice b liddell"]
    results = match_names("a p liddell", names_to_match, opts)

    expected = names_to_match -- ["alice b liddell"]

    assert Enum.all?(results, fn r -> r in expected end)
  end
end
