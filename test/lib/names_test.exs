defmodule NamesTest do
  use ExUnit.Case
  import Akin.Names, only: [compare: 2]

  test "comparing a name against a matching name, returns a 1.0 metrics" do
    %{scores: results} = compare("alice", "alice")

    assert Enum.all?(results, fn {_k, v} -> v == 1.0 end)
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

        results = Akin.match_names_metrics(b, [a, c, d])
        wins = Enum.filter(results, fn r -> r.match === 1 end) |> Enum.count()
        losses = Enum.filter(results, fn r -> r.match === 0 end) |> Enum.count()
        %{acc | wins: w + wins, losses: l + losses}
      end)
    loss_percent = x.losses/(x.wins + x.losses)*100 |> Float.round(2)

    assert loss_percent < 10.0
  end

end
