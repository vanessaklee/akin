defmodule Word do
  defstruct(
    original: nil,
    decoded: nil,
    normalized: nil,
    upper: nil,
    length: 0,
    prepad: nil,
    start_index: 0,
    end_index: 0,
    postpad: nil,
    buffer: nil
  )

  def init(input) do
    prepad = "  "
    postpad = "      "
    decoded = if String.valid?(input), do: input, else: nil
    %Word{
      original: input,
      decoded: decoded,
      normalized: normalize(input),
      upper: String.upcase(input),
      length: String.length(input),
      prepad: prepad,
      start_index: String.length(prepad),
      end_index: String.length(prepad) + (String.length(input) - 1),
      postpad: postpad,
      buffer: prepad <> String.upcase(input) <> postpad
    }
  end

  def is_slavo_germanic?(%Word{upper: upper}) do
    String.contains?(upper, "W")
    or String.contains?(upper, "K")
    or String.contains?(upper, "CZ")
    or String.contains?(upper, "WITZ")
  end

  def get_letters(%Word{start_index: start_index, buffer: buffer}, start \\ 0, close \\ nil) do
    close = if is_nil(close), do: start + 1, else: close
    start = start_index + start
    close = start_index + close
    String.slice(buffer, start, (close - start))
  end

  def normalize(input) do
    String.normalize(input, :nfd)
    |> String.graphemes()
    |> Enum.reduce([], fn l, acc ->  if Unicode.category(l) == "Mn", do: acc, else: [l | acc]  end)
    |> Enum.reverse()
  end
end
