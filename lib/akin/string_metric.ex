defmodule Akin.StringMetric do
  @moduledoc """
  Specifies the string metric api which an module needs to implement to provide
  string comparison methods
  """
  @callback compare(String.t(), String.t(), Keyword.t(any())) :: any
  @callback compare(String.t(), String.t()) :: any
  @optional_callbacks compare: 3

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)
      def compare(left, right, []), do: compare(left, right)
      def compare(left, right, opts), do: compare(left, right, opts)

      defoverridable [compare: 3]
    end
  end
end
