defmodule SubstringSortTest do
  use ExUnit.Case
  import Akin.SubstringSort, only: [compare: 2]
  import Akin.Util, only: [compose: 1]

  test "returns expected float value for comparing string containing similar words" do
    left = "alice in wonderland"
    right = "carroll's alice in wonderland"

    assert normal(left, right) == 0.83
  end

  test "returns expected float value for comparing string containing non-similar words" do
    left = "Alice Pleasance Liddell"
    right = "Alice P Liddell"

    assert normal(left, right) == 0.85
  end

  test "returns expected float value for comparing string containing even less similar words" do
    left = "Alice Pleasance Liddell"
    right = "Alice Liddell"

    assert normal(left, right) == 0.85
  end

  test "returns expected float value for comparing string containing different words" do
    left = "Alice Pleasance Liddell"
    right = "Alice Hargreaves"

    assert normal(left, right) == 0.65
  end

  test "returns expected float value for comparing string containing multiple, no similarity words" do
    left = "abc def"
    right = "ghijk lmn"

    assert normal(left, right) == 0.0
  end

  defp normal(left, right) do
    compare(compose(left), compose(right)) |> Float.round(2)
  end
end
