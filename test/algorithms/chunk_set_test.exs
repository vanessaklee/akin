defmodule SubstringSetTest do
  use ExUnit.Case
  import Akin.SubstringSet, only: [compare: 2, compare: 3]
  import Akin.Util, only: [compose: 1]

  test "returns expected float value for comparing string containing multiple, but similar words" do
    left = "alice in wonderland"
    right = "carroll's alice in wonderland"

    normal = normal(left, right)
    weak = weak(left, right)
    assert normal == 0.93
    assert normal < weak
    assert weak == 1.0
  end

  test "returns expected float value for comparing string containing multiple, non-similar words" do
    left = "alice in wonderland"
    right = "alice through the looking glass"

    normal = normal(left, right)
    assert normal == 0.79
    assert normal < weak(left, right)
  end

  test "returns expected float value for comparing string containing multiple, even less similar words" do
    left = "alice in wonderland"
    right = "my wonderlandia"

    normal = normal(left, right)
    assert normal == 0.22
    assert normal < weak(left, right)
  end

  test "returns expected float value for comparing string containing multiple, different words" do
    left = "alice in wonderland"
    right = "through the looking glass"

    normal = normal(left, right)
    assert normal == 0.15
    assert normal < weak(left, right)
  end

  test "returns expected float value for comparing string containing multiple, no similarity words" do
    left = "abc def ghijk"
    right = "lmno pq rstuvwxyz"

    assert normal(left, right) == 0.0
  end

  test "returns expected float value for comparing string of extreme length difference" do
    left = "alice in wonderland"
    right = "alice's adventures in wonderland"

    normal = normal(left, right)
    assert normal == 0.83
    assert normal < weak(left, right)
  end

  defp normal(left, right) do
    compare(compose(left), compose(right)) |> Float.round(2)
  end

  defp weak(left, right) do
    compare(compose(left), compose(right), level: "weak") |> Float.round(2)
  end
end
