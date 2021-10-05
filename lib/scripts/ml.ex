defmodule Akin.ML do

  def training_data() do
    NimbleCSV.define(CSVParse, separator: ",", escape: "\\")
    File.rm("compare.csv")

    # File.stream!("test/support/match_names.csv")
    File.stream!("test/support/match_names.csv")
    |> Stream.map(&String.trim(&1))
    |> Enum.to_list()
    |> Enum.each(fn row ->
      [left, right, match] = String.split(row, "\t")

      # Phase 1 axon
      # Akin.compare(left, right)
      # |> to_csv(left, right, match)

      # Phase 2 axon
      # case Akin.match_names_metrics(left, [right], [boost_initials: true]) do
      #   [%{left: l, right: r, metrics: s, match: m}] ->
      #     to_csv(Enum.into(s, %{}), l, r, m, match)
      #   _ -> nil
      # end

      # Phase 3 tangram
      case Akin.match_names_metrics(left, [right], [boost_initials: true]) do
        [%{left: _, right: _, metrics: scores, match: _}] ->
          # names = l <> " <- (" <> to_string(m) <> ") -> " <> r
          match = if match == "1", do: "match", else: "non-match"
          scores = Enum.into(scores, %{})
          data =
            [
              [
                scores.bag_distance,
                scores.chunk_set,
                scores.sorensen_dice,
                scores.metaphone,
                scores.double_metaphone,
                scores.double_metaphone_chunks,
                scores.jaccard,
                scores.jaro_winkler,
                scores.levenshtein,
                scores.ngram,
                scores.overlap,
                scores.sorted_chunks,
                scores.tversky,
                match
              ]
            ]
            |> CSVParse.dump_to_iodata()

          File.write!("compare.csv", [data], [:append])
        _ -> nil
      end

    end)
  end

  def tangram_data() do
    NimbleCSV.define(CSVParse, separator: "\t")
    File.rm("tangram_predictions.csv")

    # File.stream!("test/support/orcid/bench.csv")
    File.stream!("test/support/orcid/predict_a.csv")
    # File.stream!("test/support/orcid/predict_b.csv")
    |> Stream.map(&String.trim(&1))
    |> Enum.to_list()
    |> Enum.reduce(:ok, fn row, acc ->
      # Phase 4 prediction data for tangram
      # [a, b, c, d] = String.split(row, "\t")
      [_, _, _, a, _, b, _, _, _, c, d] = String.split(row, "\t")
      b = String.replace(b, "|", ", ")
      c = String.replace(c, "_", " ")
      d = String.replace(d, "_", " ")

      Akin.match_names_metrics(b, [a, c, d], [boost_initials: true])
      |> Enum.each(fn %{left: l, right: r, metrics: s, match: m} ->
        names = l <> " <- (" <> to_string(m) <> ") -> " <> r
        scores = Enum.into(s, %{})
        match = "match"
        data =
          [
            [
              scores.bag_distance,
              scores.chunk_set,
              scores.sorensen_dice,
              scores.metaphone,
              scores.double_metaphone,
              scores.double_metaphone_chunks,
              scores.jaccard,
              scores.jaro_winkler,
              scores.levenshtein,
              scores.ngram,
              scores.overlap,
              scores.sorted_chunks,
              scores.tversky,
              names,
              match
            ]
          ]
          |> CSVParse.dump_to_iodata()

        File.write!("tangram_predictions.csv", [data], [:append])
      end)
      acc
    end)
  end
end
