defmodule X6502.Memory do
  use Bitwise

  @doc """
  Creates a new memory page of up to 65535 bytes.

  ## Examples

      iex> X6502.Memory.new :main
      :main

  """
  @spec new(atom()):: atom()
  def new(name) do
    :ets.new(
      name, [
        :named_table, :public, :ordered_set,
        {:read_concurrency, false}, {:write_concurrency, false}
      ]
    )
    name
  end

  @doc """
  Creates a new memory page of up to 65535 bytes with the given list of bytes.

  ## Examples

      iex> X6502.Memory.new :main, [0x00, 0x01, 0x02, 0x03]
      :main
      iex> X6502.Memory.peek m, 0x00
      0x00
      iex> X6502.Memory.peek m, 0x01
      0x01
      iex> X6502.Memory.peek m, 0x02
      0x02
      iex> X6502.Memory.peek m, 0x03
      0x03

  """
  @spec new(atom(), [byte()]|binary()):: atom()
  def new(name, bytes) when is_list(bytes) do
    m = new name
    Enum.reduce(bytes, 0, fn(b, i) ->
      poke(m, i, b)
      i + 1
    end)
    m
  end

  @doc """
  Creates a new memory page of up to 65535 bytes with the given binary.

  ## Examples

      iex> m = X6502.Memory.new :main, <<0x00, 0x01, 0x02, 0x03>>
      iex> X6502.Memory.peek m, 0x00
      0x00
      iex> X6502.Memory.peek m, 0x01
      0x01
      iex> X6502.Memory.peek m, 0x02
      0x02
      iex> X6502.Memory.peek m, 0x03
      0x03
  """
  def new(name, bytes) when is_binary(bytes) do
    m = new name
    len = byte_size(bytes) - 1
    Enum.reduce(0..len, bytes, fn(i, <<b::size(8), r::binary>>) ->
      poke(m, i, b)
      r
    end)
    m
  end

  @doc """
  Inserts the given 8bit binary into the given memory offset.

  ## Examples

      iex> m = X6502.Memory.new :main, [0x00, 0x01, 0x02, 0x03]
      :main
      iex> X6502.Memory.poke m, 0x03, 0x04
      :ok
      iex> X6502.Memory.peek m, 0x03
      0x04

  """
  @spec poke(atom(), 0..65535, byte()):: :ok
  def poke(memory, offset, value) do
    :ets.insert memory, {offset, value &&& 0xFF}
    :ok
  end

  @doc """
  Retrieves a byte from the given memory offset.

  ## Examples

      iex> m = X6502.Memory.new :main, [0x00, 0x01, 0x02, 0x03]
      :main
      iex> X6502.Memory.peek m, 0x02
      0x02

  """
  @spec peek(atom(), 0..65535):: byte()
  def peek(memory, offset) do
    case :ets.lookup(memory, offset) do
      [{_offset, value}] -> value
      [] -> 0x00
    end
  end
end