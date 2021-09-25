defmodule DoubleHomophoneTest do
  @moduledoc """
  Tests to cover double metaphone algorithm using homophones.
  """
  use ExUnit.Case
  import Akin.Metaphone.Double
  alias NimbleCSV.RFC4180, as: CSV

  test "double metaphone normal compare suceeds if homophones phonetically match" do
    {:ok, data} = File.read("test/support/homophones/phonetic_matches.csv")
    homophones = data
      |> CSV.parse_string

    for homophone <- homophones do
      case homophone do
        [a, b] ->
          assert compare(parse(a), parse(b))
        [a, b, c] ->
          assert compare(parse(a), parse(b))
          assert compare(parse(b), parse(c))
          assert compare(parse(a), parse(c))
        _ -> nil
      end
    end
  end

  test "double metaphone normal compare fails if homophones do not phonetically match" do
    {:ok, data} = File.read("test/support/homophones/phonetic_nonmatches.csv")
    homophones = data
      |> CSV.parse_string

    for homophone <- homophones do
      case homophone do
        [a, b] ->
          refute compare(parse(a), parse(b))
        _ -> nil
      end
    end
  end

  test "double metaphone weak compare suceeds if homophones phonetically match" do
    {:ok, data} = File.read("test/support/homophones/phonetic_matches.csv")
    homophones = data
      |> CSV.parse_string

    for homophone <- homophones do
      case homophone do
        [a, b] ->
          assert compare(parse(a), parse(b), "weak")
        [a, b, c] ->
          assert compare(parse(a), parse(b), "weak")
          assert compare(parse(b), parse(c), "weak")
          assert compare(parse(a), parse(c), "weak")
        _ -> nil
      end
    end
  end

  test "double metaphone strict compare suceeds if homophones phonetically match" do
    {:ok, data} = File.read("test/support/homophones/phonetic_strict_matches.csv")
    homophones = data
      |> CSV.parse_string

    for homophone <- homophones do
      case homophone do
        [a, b] ->
          assert compare(parse(a), parse(b), "strict")
        [a, b, c] ->
          assert compare(parse(a), parse(b), "strict")
          assert compare(parse(b), parse(c), "strict")
          assert compare(parse(a), parse(c), "strict")
        _ -> nil
      end
    end
  end

  test "double metaphone strict compare fails if homophones do not phonetically match" do
    {:ok, data} = File.read("test/support/homophones/phonetic_strict_nonmatches.csv")
    homophones = data
      |> CSV.parse_string

    for homophone <- homophones do
      case homophone do
        [a, b] ->
          refute compare(parse(a), parse(b), "strict")
        _ -> nil
      end
    end
  end
end
