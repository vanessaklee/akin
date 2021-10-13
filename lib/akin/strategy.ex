defmodule Akin.Strategy do
  @moduledoc """
  Determine whether all comparison functions should use the simple ratio function or
  the substring ratio function.
  """
  @substring_similarity_threshold 1.5
  @substring_default_scale 0.9
  @one_string_much_longer_threshold 8
  @one_string_much_longer_scale 0.6

  def determine(left, right) do
    left_length = String.length(left)
    right_length = String.length(right)
    determine(left, right, left_length, right_length)
  end

  def determine(_left, _right, left_length, right_length)
      when left_length > 0 and right_length > 0 do
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

  def determine(_, _, _, _), do: {:error, nil}
end
