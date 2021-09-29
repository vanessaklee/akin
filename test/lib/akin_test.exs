defmodule AkinTest do
  use ExUnit.Case
  import Akin

  test "comparing two exact strings returns all 1.0 values" do
    results = compare("vanessa", "vanessa")

    assert Enum.all?(results, fn {_k, v} -> v == 1.0 end)
  end
end
