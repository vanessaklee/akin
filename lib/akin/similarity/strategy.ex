defmodule Akin.Similarity.Strategy do
  @moduledoc """
  This module is used to determine whether all comparison functions should use
  the simple ratio function or the substring ratio function.
  """
  alias Akin.Similarity.Preprocessed

  @substring_similarity_threshold 1.5
  @substring_default_scale 0.9
  @one_string_much_longer_threshold 8
  @one_string_much_longer_scale 0.6

  def determine_strategy(%Preprocessed{string: left}, %Preprocessed{string: right}) do
    left_length = String.length(left)
    right_length = String.length(right)

    length_ratio = Enum.max([left_length, right_length]) / Enum.min([left_length, right_length])

    cond do
      length_ratio < @substring_similarity_threshold ->
        :standard

      @one_string_much_longer_threshold < length_ratio ->
        {:substring, @one_string_much_longer_scale}

      true ->
        {:substring, @substring_default_scale}
    end
  end
end
