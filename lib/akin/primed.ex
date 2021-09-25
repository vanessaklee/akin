defmodule Akin.Primed do
  @moduledoc """
  Struct to hold the string after it has been primed for disambiguation.
  """
  defstruct [:set, :chunks, :string, :stems]
end
