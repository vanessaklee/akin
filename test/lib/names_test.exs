defmodule NamesTest do
  use ExUnit.Case
  import Akin.Names, only: [compare: 2, compare: 3]

  test "comparing a name against a matching name, returns a 1.0 metrics" do
    results = compare("alice", "alice")

    assert Enum.all?(results, fn {_k, v} -> v == 1.0 end)
  end

  test "names with initials compared against a name matching those initials receives metrics boost if opt is set" do
    [chunk_set: results_without] = compare("a p liddell", "alice pleasance liddell")
    opts = Keyword.put(Akin.default_opts(), :match_left_initials, true)
    [chunk_set: results_with] = compare("a p liddell", "alice pleasance liddell", opts)

    assert results_with > results_without
  end

  test "names with initials right name are not given a boost even if opt is set" do
    [chunk_set: results_without] = compare("alice pleasance liddel", "a p liddel")
    [chunk_set: results_with] = compare("alice pleasance liddel", "a p liddel", [match_left_initials: true])

    assert results_with == results_without
  end
end
