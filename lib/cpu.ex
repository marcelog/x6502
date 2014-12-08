defmodule X6502.CPU do
  defstruct registers: %{}, memory: %{}, mm: nil

  alias X6502.DU, as: DU
  alias X6502.EU, as: EU

  def new(_, mm \\ X6502.Memory)
  def new(memory_bytes, mm) when is_list(memory_bytes) do
    %X6502.CPU{
      registers: create_registers,
      mm: mm,
      memory: mm.new(:main, memory_bytes)
    }
  end

  def new(memory_data, mm) do
    %X6502.CPU{
      registers: create_registers,
      mm: mm,
      memory: memory_data
    }
  end

  def next(state = %X6502.CPU{mm: mm, memory: memory, registers: registers}) do
    pc = registers[:pc]
    instruction = DU.decode mm.peek(memory, pc)
    EU.execute instruction, state
  end

  defp create_registers do
    %{
      a: 0x00,
      pc: 0x00,
      sp: 0xFF,
      p: 36, # I = 1, Bit5 = 1
      x: 0x00,
      y: 0x00
    }
  end
end
