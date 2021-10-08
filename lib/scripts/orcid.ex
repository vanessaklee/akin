defmodule Orcid do

  def prep() do
    File.rm("test/support/orcid/match_names.csv")

    File.stream!("test/support/orcid/mini.csv")
    |> Stream.map(&String.trim(&1))
    |> Enum.to_list()
    |> Enum.map(fn row ->
      [a, b, c, d] = String.split(row, "\t")
      b = String.replace(b, "|", ", ")
      c = String.replace(c, "_", " ")
      d = String.replace(d, "_", " ")

      Akin.match_names_metrics(b, [a, c, d])
      |> Enum.each(fn m -> to_csv(m) end)
    end)
  end

  def to_csv(map) do
    m = Map.get(map, :match)
    r = Map.get(map, :right)
    l = Map.get(map, :left)
    list = Map.get(map, :metrics)
    cs = Keyword.get(list, :substring_set) || 0.0
    sc = Keyword.get(list, :substring_sort) || 0.0
    dmc = Keyword.get(list, :substring_double_metaphone) || 0.0
    o = Keyword.get(list, :overlap) || 0.0

    cs = cs |> Float.round(2)
    sc = sc |> Float.round(2)
    dmc = dmc |> Float.round(2)
    o = o |> Float.round(2)

    match = if m, do: 1, else: 0
    data =
      [
        [
          cs,
          sc,
          dmc,
          o,
          match,
          l,
          r
        ]
      ]
      |> CSVParse.dump_to_iodata()

    File.write!("test/support/orcid/match_names.csv", [data], [:append])
  end
end
