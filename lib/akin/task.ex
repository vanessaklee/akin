defmodule Akin.Task do
  @moduledoc """
  API for all string comparison modules.
  """
  @callback compare(%Akin.Corpus{}, %Akin.Corpus{}, Keyword.t(any())) :: number() | map()
  @callback compare(%Akin.Corpus{}, %Akin.Corpus{}) :: number() | map()
  @optional_callbacks compare: 2
end
