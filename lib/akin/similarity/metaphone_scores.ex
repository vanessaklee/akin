defmodule Akin.Similarity.MetaphoneScores do
  @moduledoc """
  Calculates the [Metaphone Phonetic Algorithm](http://en.wikipedia.org/wiki/
  Metaphone) metric of two strings.
  """
  # @behaviour Akin.StringMetric
  use Akin.StringMetric

  import Akin.Phonetic.Metaphone, only: [compute: 1]
  import Akin.Util, only: [len: 1, is_alphabetic?: 1, modulize: 1]
  import Akin.AuthorUtil, only: [normalize: 1, deaccentize: 1]
  import String, only: [first: 1]
  alias Akin.Similarity.Preprocessor
  @comparison_algorithms [:bag_distance, :jaro_winkler, :levenshtein, :chunk_set, :sorted_chunks]

  @doc """
    Determines the phonetic values of two strings and returns a map of the comparison scores
    of those values using the algorithms in the module var @comparison_algorithms

    ## Examples
      iex> Akin.Similarity.MetaphoneScores.compare("Colorado", "Kolorado")
      %{levenshtein: 1, bag_distance: 1.0, chunk_set: 1.0, jaro_winkler: 1.0, sorted_chunks: 1.0}
      iex> Akin.Similarity.MetaphoneScores.compare("Moose", "Elk")
      %{
        bag_distance: 0.0,
        chunk_set: 0.0,
        jaro_winkler: 0.0,
        levenshtein: 3,
        sorted_chunks: 0.0
      }
  """
  def compare(left, right) do
    case len(left) == 0 || !is_alphabetic?(first(left)) || len(right) == 0 || !is_alphabetic?(first(right)) do
      false ->
        {processed_left, processed_right} = Preprocessor.process(left, right)
        cleft = Enum.map(processed_left.chunks, fn chunk ->
          chunk
          |> normalize()
          |> deaccentize()
          |> compute()
        end)
        cright = Enum.map(processed_right.chunks, fn chunk ->
          chunk
          |> normalize()
          |> deaccentize()
          |> compute()
        end)
        if Enum.count(cleft) == Enum.count(cright) do
          # TODO compare each part, not just the whole
          # combined = Enum.zip(cleft, cright)
          Enum.reduce(@comparison_algorithms, %{}, fn algorithm, acc ->
            args = [
              Enum.join(cleft, " "),
              Enum.join(cright, " " )
            ]
            Map.put(acc, algorithm, apply(modulize(algorithm), :compare, args))
          end)
        else
          # TODO - handle these situations where the names parts do not match expectations
          nil
        end
      true ->
        nil
    end
  end
end
