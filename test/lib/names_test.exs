defmodule NamesTest do
  use ExUnit.Case
  import Akin.NamesMetric, only: [compare: 2, compare: 3]

  test "comparing a name against a matching name, returns a 1.0 metrics" do
    results = compare("alice", "alice")

    assert Enum.all?(results, fn {_k, v} -> v == 1.0 end)
  end

  test "names with initials compared against a name matching those initials receives metrics boost if opt is set" do
    results_without = compare("a p liddell", "alice pleasance liddell") |> Keyword.values() |> List.first()
    opts = Keyword.put(Akin.default_opts(), :boost_initials, true)
    results_with = compare("a p liddell", "alice pleasance liddell", opts) |> Keyword.values() |> List.first()

    assert results_with > results_without
  end

  test "known names in orcid should all match" do
    File.rm("test/support/orcid/match_names.csv")

    x = File.stream!("test/support/orcid/mini.csv")
      |> Stream.map(&String.trim(&1))
      |> Enum.to_list()
      |> Enum.reduce(%{wins: 0, losses: 0}, fn row, %{wins: w, losses: l} = acc ->
        [a, b, c, d] = String.split(row, "\t")
        b = String.replace(b, "|", ", ")
        c = String.replace(c, "_", " ")
        d = String.replace(d, "_", " ")

        # results = Akin.match_names_metrics(b, [a, c, d], [boost_initials: false])
        results = Akin.match_names_metrics(b, [a, c, d], [boost_initials: true])
        wins = Enum.filter(results, fn r -> r.match === 1 end) |> Enum.count()
        losses = Enum.filter(results, fn r -> r.match === 0 end) |> Enum.count()
        %{acc | wins: w + wins, losses: l + losses}
      end)
    loss_percent = x.losses/(x.wins + x.losses)*100 |> Float.round(2)
    # win_percent =x.wins/(x.wins + x.losses)*100 |> Float.round(2)
    # IO.inspect loss_percent
    # IO.inspect win_percent

    assert loss_percent < 10.0
  end

end
