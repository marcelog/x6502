defmodule X6502.CPU do
  defstruct registers: %{}, memory: %{}, mm: nil

  alias X6502.DU, as: DU
  alias X6502.EU, as: EU

  def new(memory_bytes, mm \\ X6502.Memory) do
    %X6502.CPU{
      registers: %{
        a: 0x00,
        pc: 0x00,
        sp: 0xFF,
        p: 36, # I = 1, Bit5 = 1
        x: 0x00,
        y: 0x00
      },
      mm: mm,
      memory: mm.new(:main, memory_bytes)
    }
  end

  def next(state = %X6502.CPU{mm: mm, memory: memory, registers: registers}) do
    pc= registers[:pc]
    instruction = DU.decode mm.peek(memory, pc)
    EU.execute instruction, state
  end
end
