defmodule Akin.ML do
  def training_data() do
    NimbleCSV.define(CSVParse, separator: ",", escape: "\\")
    File.rm("test/support/metrics_for_training.csv")

    # File.stream!("test/support/dblp_for_training.csv")
    File.stream!("test/support/nonmatches_for_training.csv")
    |> Stream.map(&String.trim(&1))
    |> Enum.to_list()
    |> Enum.each(fn row ->
      # [left, right, _match] = String.split(row, "\t")
      [left, right] = String.split(row, "\t")

      case Akin.match_names_metrics(left, [right]) do
        [%{left: _, right: _, metrics: scores, match: _}] ->
          # names = l <> " <- (" <> to_string(m) <> ") -> " <> r
          # match = if match == "1", do: "match", else: "non-match"
          scores = Enum.into(scores, %{})

          data =
            [
              [
                scores.bag_distance,
                scores.substring_set,
                scores.sorensen_dice,
                scores.metaphone,
                scores.double_metaphone,
                scores.substring_double_metaphone,
                scores.jaccard,
                scores.jaro_winkler,
                scores.levenshtein,
                scores.ngram,
                scores.overlap,
                scores.substring_sort,
                scores.tversky,
                scores.initials,
                "non-match"
              ]
            ]
            |> CSVParse.dump_to_iodata()

          File.write!("test/support/nonmatching_metrics_for_training.csv", [data], [:append])

        _ ->
          nil
      end
    end)
  end

  def tangram_data() do
    NimbleCSV.define(CSVParse, separator: "\t")
    File.rm("test/support/metrics_for_predicting.csv")

    File.stream!("test/support/orcid/predict_b.csv")
    # File.stream!("test/support/orcid_for_predicting.csv")
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

      Akin.match_names_metrics(b, [a, c, d])
      |> Enum.each(fn %{left: l, right: r, metrics: s, match: m} ->
        names = l <> " <- (" <> to_string(m) <> ") -> " <> r
        scores = Enum.into(s, %{})
        match = "match"

        data =
          [
            [
              scores.bag_distance,
              scores.substring_set,
              scores.sorensen_dice,
              scores.metaphone,
              scores.double_metaphone,
              scores.substring_double_metaphone,
              scores.jaccard,
              scores.jaro_winkler,
              scores.levenshtein,
              scores.ngram,
              scores.overlap,
              scores.substring_sort,
              scores.tversky,
              scores.initials,
              match
            ]
          ]
          |> CSVParse.dump_to_iodata()

        IO.inspect File.write!("test/support/orcid_metrics_for_predicting.csv", [data], [:append])
      end)

      acc
    end)
  end

  def tangram_data2() do
    NimbleCSV.define(CSVParse, separator: "\t")
    File.rm("test/support/metrics_for_predicting_nonmatch.csv")

    File.stream!("test/support/nonmatches_for_predicting.csv")
    # File.stream!("test/support/orcid/predict_b.csv")
    |> Stream.map(&String.trim(&1))
    |> Enum.to_list()
    |> Enum.reduce(:ok, fn row, acc ->
      # Phase 4 prediction data for tangram
      # [a, b, c, d] = String.split(row, "\t")
      [a, b, _c] = String.split(row, "\t")

      Akin.match_names_metrics(a, [b])
      |> Enum.each(fn %{left: l, right: r, metrics: s, match: m} ->
        names = l <> " <- (" <> to_string(m) <> ") -> " <> r
        scores = Enum.into(s, %{})
        match = "nonmatch"

        data =
          [
            [
              scores.bag_distance,
              scores.substring_set,
              scores.sorensen_dice,
              scores.metaphone,
              scores.double_metaphone,
              scores.substring_double_metaphone,
              scores.jaccard,
              scores.jaro_winkler,
              scores.levenshtein,
              scores.ngram,
              scores.overlap,
              scores.substring_sort,
              scores.tversky,
              scores.initials,
              names,
              match
            ]
          ]
          |> CSVParse.dump_to_iodata()

        File.write!("test/support/metrics_for_predicting_nonmatch.csv", [data], [:append])
      end)

      acc
    end)
  end
end
