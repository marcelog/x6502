defmodule X6502.AU do
  use Bitwise
  alias X6502.CPU, as: CPU

  @doc """
  6502 addressing modes. Returns the memory location of the operand 16bits wide.

  ## Examples
      iex> X6502.AU.address(
      ...>   :accumulator,
      ...>   %X6502.CPU{mm: X6502.Memory, registers: %{pc: 0x00}}
      ...> )
      nil

      iex> X6502.AU.address(
      ...>   :implied,
      ...>   %X6502.CPU{mm: X6502.Memory, registers: %{pc: 0x00}}
      ...> )
      nil

      iex> X6502.AU.address(
      ...>   :immediate,
      ...>   %X6502.CPU{mm: X6502.Memory, registers: %{pc: 0x0055}}
      ...> )
      0x56

      iex> m = X6502.Memory.new :main, [0x01, 0x02, 0x55]
      iex> X6502.AU.address(
      ...>   :zero_page_direct,
      ...>   %X6502.CPU{
      ...>     memory: m,
      ...>     mm: X6502.Memory,
      ...>     registers: %{
      ...>       pc: 0x0001
      ...>     }
      ...>   }
      ...> )
      0x55

      iex> m = X6502.Memory.new :main
      iex> X6502.Memory.poke m, 0x34, 0x54
      iex> X6502.Memory.poke m, 0x55, 0xCD
      iex> X6502.Memory.poke m, 0x56, 0xAB
      iex> X6502.AU.address(
      ...>   :zero_page_preindex,
      ...>   %X6502.CPU{
      ...>     memory: m,
      ...>     mm: X6502.Memory,
      ...>     registers: %{
      ...>       pc: 0x0033,
      ...>       x: 0x01
      ...>     }
      ...>   }
      ...> )
      0xABCD

      iex> m = X6502.Memory.new :main
      iex> X6502.Memory.poke m, 0x34, 0x54
      iex> X6502.Memory.poke m, 0x54, 0xCC
      iex> X6502.Memory.poke m, 0x55, 0xAB
      iex> X6502.AU.address(
      ...>   :zero_page_postindex,
      ...>   %X6502.CPU{
      ...>     memory: m,
      ...>     mm: X6502.Memory,
      ...>     registers: %{
      ...>       pc: 0x0033,
      ...>       y: 0x01
      ...>     }
      ...>   }
      ...> )
      0xABCD

      iex> m = X6502.Memory.new :main
      iex> X6502.Memory.poke m, 0x34, 0x54
      iex> X6502.AU.address(
      ...>   :zero_page_indexed_x,
      ...>   %X6502.CPU{
      ...>     memory: m,
      ...>     mm: X6502.Memory,
      ...>     registers: %{
      ...>       pc: 0x0033,
      ...>       x: 0x01
      ...>     }
      ...>   }
      ...> )
      0x0055

      iex> m = X6502.Memory.new :main
      iex> X6502.Memory.poke m, 0x34, 0x54
      iex> X6502.AU.address(
      ...>   :zero_page_indexed_y,
      ...>   %X6502.CPU{
      ...>     memory: m,
      ...>     mm: X6502.Memory,
      ...>     registers: %{
      ...>       pc: 0x0033,
      ...>       y: 0x01
      ...>     }
      ...>   }
      ...> )
      0x0055

      iex> m = X6502.Memory.new :main
      iex> X6502.Memory.poke m, 0x34, 0xCC
      iex> X6502.Memory.poke m, 0x35, 0xAB
      iex> X6502.AU.address(
      ...>   :absolute_indexed_x,
      ...>   %X6502.CPU{
      ...>     memory: m,
      ...>     mm: X6502.Memory,
      ...>     registers: %{
      ...>       pc: 0x0033,
      ...>       x: 0x01
      ...>     }
      ...>   }
      ...> )
      0xABCD

      iex> m = X6502.Memory.new :main
      iex> X6502.Memory.poke m, 0x34, 0xCC
      iex> X6502.Memory.poke m, 0x35, 0xAB
      iex> X6502.AU.address(
      ...>   :absolute_indexed_y,
      ...>   %X6502.CPU{
      ...>     memory: m,
      ...>     mm: X6502.Memory,
      ...>     registers: %{
      ...>       pc: 0x0033,
      ...>       y: 0x01
      ...>     }
      ...>   }
      ...> )
      0xABCD
  """
  # The instructions operate on the data in the Accumulator (e.g: ASL)
  def address(:accumulator, state) do
    address :implied, state
  end

  # No addresses are required to execute the instruction (e.g: CLC)
  def address(:implied, _state) do
    nil
  end

  # One of the operands is present in the byte immediately following the first
  # byte of object code.
  def address(:immediate, %CPU{
    registers: %{pc: pc}
  }) do
    inc_pc pc
  end

  # Uses the second -- or second and third (if not on zero, or base page) -- of
  # the instruction to identify the address of an operand in memory.
  def address(:zero_page_direct, %CPU{
    mm: mm,
    memory: memory,
    registers: %{pc: pc}
  }) do
    to_16bits 0, mm.peek(memory, inc_pc(pc))
  end

  def address(:absolute, %CPU{
    mm: mm,
    memory: memory,
    registers: %{pc: pc}
  }) do
    l = mm.peek memory, inc_pc(pc, 1)
    h = mm.peek memory, inc_pc(pc, 2)
    to_16bits h, l
  end

  # The second byte of the instruction is added to the contents of the X Index
  # register to access a memory location in the first 256 bytes of memory, where
  # the indirect address will be found.
  def address(:zero_page_preindex, %CPU{
    mm: mm,
    memory: memory,
    registers: %{
      pc: pc,
      x: x
    }
  }) do
    op_address = mm.peek memory, inc_pc(pc, 1)
    pre_address_l = inc_address op_address, x
    pre_address_h = inc_address pre_address_l, 1
    l = mm.peek memory, pre_address_l
    h = mm.peek memory, pre_address_h
    to_16bits h, l
  end

  # The second byte of the instruction contains an address in the first 256
  # bytes of memory. That address and the next location contain an address
  # which is added to the contents of the Y Index register to obtain the
  # effective address.
  def address(:zero_page_postindex, %CPU{
    mm: mm,
    memory: memory,
    registers: %{
      pc: pc,
      y: y
    }
  }) do
    pre_address_l = to_16bits(
      0, mm.peek(memory, inc_pc(pc, 1))
    )
    l = mm.peek memory, pre_address_l
    h = mm.peek memory, inc_address(pre_address_l, 1)
    inc_address to_16bits(h, l), y
  end

  # Uses the second -- or second and third (if not on zero page) -- bytes of the
  # instruction to specify the base address. That base address is then added to
  # the contents of the Index Register X or Y to get the effective address.
  def address(:zero_page_indexed_x, %CPU{
    mm: mm,
    memory: memory,
    registers: %{
      pc: pc,
      x: x
    }
  }) do
    op_address = mm.peek memory, inc_pc(pc, 1)
    address = inc_address_8 op_address, x
    to_16bits 0, address
  end

  def address(:zero_page_indexed_y, %CPU{
    mm: mm,
    memory: memory,
    registers: %{
      pc: pc,
      y: y
    }
  }) do
    op_address = mm.peek memory, inc_pc(pc, 1)
    address = inc_address_8 op_address, y
    to_16bits 0, address
  end

  def address(:absolute_indexed_x, %CPU{
    mm: mm,
    memory: memory,
    registers: %{
      pc: pc,
      x: x
    }
  }) do
    l = mm.peek memory, inc_pc(pc, 1)
    h = mm.peek memory, inc_pc(pc, 2)
    inc_address to_16bits(h, l), x
  end

  def address(:absolute_indexed_y, %CPU{
    mm: mm,
    memory: memory,
    registers: %{
      pc: pc,
      y: y
    }
  }) do
    l = mm.peek memory, inc_pc(pc, 1)
    h = mm.peek memory, inc_pc(pc, 2)
    inc_address to_16bits(h, l), y
  end

  ##############################################################################
  # Helpers used to handle 16bits addresses.
  ##############################################################################
  def to_16bits(h, l) do
    to_16bits((h <<< 8) + l)
  end

  defp inc_pc(pc, n \\ 1) do
    inc_address pc, n
  end

  def inc_address_8(a, n) do
    ((a &&& 0xFF) + n) &&& 0xFF
  end

  defp inc_address(a, b) do
    to_16bits(a + b)
  end

  defp to_16bits(x) do
    x &&& 0xFFFF
  end
end
