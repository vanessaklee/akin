defmodule Akin.Similarity.Preprocessor do
  @moduledoc """
  This module allows for the preprocessing of strings which will be used in the
  comparision. Preprocessing is vital for high quality results. During
  processing the input strings are upcased, all punctuation is stripped,
  excess whitespace is trimmed and a Map of values is returned which is used
  by all other comparison functions. This allows for the reuse of preprocessed
  values and prevents each comparison function from rerunning the preprocessing.
  """

  alias Akin.Similarity.Preprocessed

  # Replaces all punctuation
  @regex ~r/[\p{P}\p{S}]/

  def process(left, right) when is_binary(left) and is_binary(right) do
    {process(left), process(right)}
  end

  def process(string) when is_binary(string) do
    chunks =
      string
      |> String.replace(@regex, " ")
      |> String.downcase()
      |> String.split()
      |> Enum.map(&String.trim/1)

    %Preprocessed{
      set: MapSet.new(chunks),
      chunks: chunks,
      string: Enum.join(chunks)
    }
  end
end
