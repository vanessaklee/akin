defmodule Akin.ML do
  @compare_file "compare.csv"
  @compare_mini_file "compare-mini.csv"

  def training_data() do
    File.rm(@compare_file)
    File.rm(@compare_mini_file)

    File.stream!("test/support/match_names.csv")
    |> Stream.map(&String.trim(&1))
    |> Enum.to_list()
    |> Enum.map(fn row ->
      [left, right] = String.split(row, "\t")

      Akin.compare(left, right)
      |> to_csv(left, right, 1)
    end)

    File.stream!("test/support/nonmatch_names.csv")
    |> Stream.map(&String.trim(&1))
    |> Enum.to_list()
    |> Enum.map(fn row ->
      [left, right] = String.split(row, "\t")

      Akin.compare(left, right)
      |> to_csv(left, right, 0)
    end)
  end

  defp to_csv(%{} = scores, left, right, match) do
    # TODO why is metaphone sometimes missing?
    metaphone =
      if Map.get(scores, :metaphone) do
        Map.get(scores, :metaphone)
      else
        0.0
      end

    names = left <> " compared to " <> right

    data =
      [
        [
          scores.bag_distance,
          scores.chunk_set,
          scores.dice_sorensen,
          scores.double_metaphone,
          scores.double_metaphone_chunks,
          scores.jaccard,
          scores.jaro_winkler,
          scores.levenshtein,
          metaphone,
          scores.ngram,
          scores.overlap,
          scores.sorted_chunks,
          scores.tversky,
          match,
          names
        ]
      ]
      |> CSVParse.dump_to_iodata()

    File.write!(@compare_file, [data], [:append])

    data =
      [
        [
          scores.double_metaphone_chunks,
          scores.jaccard,
          scores.jaro_winkler,
          match,
          names
        ]
      ]
      |> CSVParse.dump_to_iodata()

    File.write!(@compare_mini_file, [data], [:append])

    scores
  end
end
