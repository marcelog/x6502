defmodule X6502.CPU do
  defstruct registers: %{}, memory: %{}, mm: nil

  alias X6502.DU, as: DU
  alias X6502.EU, as: EU

  def new(_, mm \\ X6502.Memory, pc \\ 0x0000)
  def new(memory_bytes, mm, pc) when is_list(memory_bytes) do
    %X6502.CPU{
      registers: create_registers(pc),
      mm: mm,
      memory: mm.new(:main, memory_bytes)
    }
  end

  def new(memory_data, mm, pc) do
    %X6502.CPU{
      registers: create_registers(pc),
      mm: mm,
      memory: memory_data
    }
  end

  def next(state = %X6502.CPU{mm: mm, memory: memory, registers: registers}) do
    pc = registers[:pc]
    instruction = DU.decode mm.peek(memory, pc)
    EU.execute instruction, state
  end

  defp create_registers(pc) do
    %{
      a: 0x00,
      pc: pc,
      sp: 0xFF,
      p: 36, # I = 1, Bit5 = 1
      x: 0x00,
      y: 0x00
    }
  end
end
