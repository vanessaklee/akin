defmodule Akin.Corpus do
  @moduledoc """
  Struct to hold the multi-form elements which results from normalizing, splitting, and
  stemming the string prior to comparison with another string: MapSet, List, String,
  and Stemmed List.

  In Linguistics, a corpus is a collection of written or spoken eleemtns in machine-readable
   form, made to study linguistic structures, frequencies, etc.
  """
  defstruct [:set, :list, :string, :stems, :original]
end
