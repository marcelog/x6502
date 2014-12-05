defmodule X6502.CPU do
  defstruct registers: %{}, memory: %{}

  alias X6502.Memory, as: Memory
  alias X6502.DU, as: DU
  alias X6502.EU, as: EU

  def new(memory_bytes) do
    %X6502.CPU{
      registers: %{
        a: 0x00,
        pc: 0x00,
        sp: 0xFF,
        p: 36, # I = 1, Bit5 = 1
        x: 0x00,
        y: 0x00
      },
      memory: Memory.new(:main, memory_bytes)
    }
  end

  def next(state = %X6502.CPU{memory: memory, registers: registers}) do
    pc= registers[:pc]
    instruction = DU.decode Memory.peek(memory, pc)
    EU.execute instruction, state
  end
end
