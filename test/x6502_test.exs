defmodule X6502Test do
  use ExUnit.Case
  doctest X6502.ALU
  doctest X6502.Memory
  doctest X6502.AU
  doctest X6502.CPU
  doctest X6502.StatusRegister

  alias X6502.CPU, as: CPU
  alias X6502.Memory, as: Memory
  alias X6502.StatusRegister, as: StatusRegister

  test "lda generic" do
    %CPU{registers: %{a: a, p: p}} = execute [0xA5, 0x02, 0x01]
    assert 0x01 == a
    assert not StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "lda generic with immediate" do
    %CPU{registers: %{a: a, p: p}} = execute [0xA9, 0x01]
    assert 0x01 == a
    assert not StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "lda generic sets sign with bit 7 of result" do
    %CPU{registers: %{a: a, p: p}} = execute [0xA5, 0x02, 0x80]
    assert 0x80 == a
    assert not StatusRegister.zero?(p)
    assert StatusRegister.sign?(p)
  end

  test "lda generic sets zero on result == 0" do
    %CPU{registers: %{a: a, p: p}} = execute [0xA5, 0x02, 0x00]
    assert 0x00 == a
    assert StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "sta generic" do
    %CPU{memory: memory} = execute [0xA5, 0x04, 0x85, 0x05, 0xFF, 0x00], 2
    assert Memory.peek(memory, 0x05) == 0xFF
  end

  test "ldx generic" do
    %CPU{registers: %{x: x, p: p}} = execute [0xA6, 0x02, 0x01]
    assert 0x01 == x
    assert not StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "ldx generic with immediate" do
    %CPU{registers: %{x: x, p: p}} = execute [0xA2, 0x01]
    assert 0x01 == x
    assert not StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "ldx generic sets sign with bit 7 of result" do
    %CPU{registers: %{x: x, p: p}} = execute [0xA6, 0x02, 0x80]
    assert 0x80 == x
    assert not StatusRegister.zero?(p)
    assert StatusRegister.sign?(p)
  end

  test "ldx generic sets zero on result == 0" do
    %CPU{registers: %{x: x, p: p}} = execute [0xA6, 0x02, 0x00]
    assert 0x00 == x
    assert StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "stx generic" do
    %CPU{memory: memory} = execute [0xA6, 0x04, 0x86, 0x05, 0xFF, 0x00], 2
    assert Memory.peek(memory, 0x05) == 0xFF
  end

  test "ldy generic" do
    %CPU{registers: %{y: y, p: p}} = execute [0xA0, 0x01]
    assert 0x01 == y
    assert not StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "ldy generic with immediate" do
    %CPU{registers: %{y: y, p: p}} = execute [0xA4, 0x02, 0x01]
    assert 0x01 == y
    assert not StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "ldy generic sets sign with bit 7 of result" do
    %CPU{registers: %{y: y, p: p}} = execute [0xA4, 0x02, 0x80]
    assert 0x80 == y
    assert not StatusRegister.zero?(p)
    assert StatusRegister.sign?(p)
  end

  test "ldy generic sets zero on result == 0" do
    %CPU{registers: %{y: y, p: p}} = execute [0xA4, 0x02, 0x00]
    assert 0x00 == y
    assert StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "sty generic" do
    %CPU{memory: memory} = execute [0xA4, 0x04, 0x84, 0x05, 0xFF, 0x00], 2
    assert Memory.peek(memory, 0x05) == 0xFF
  end

  test "adc generic" do
    %CPU{registers: %{p: p, a: a}} = execute [0x65, 0x02, 0x04]
    assert 0x04 == a
    assert not StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.overflow?(p)
    assert not StatusRegister.carry?(p)
  end

  test "adc generic with immediate" do
    %CPU{registers: %{p: p, a: a}} = execute [0x69, 0x04]
    assert 0x04 == a
    assert not StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.overflow?(p)
    assert not StatusRegister.carry?(p)
  end

  test "adc generic sets carry" do
    %CPU{registers: %{p: p, a: a}} = execute [0x69, 0xFF, 0x69, 0x01], 2
    assert 0x00 == a
    assert StatusRegister.carry?(p)
  end

  test "adc generic sets sign" do
    %CPU{registers: %{p: p, a: a}} = execute [0x69, 0x7F, 0x69, 0x01], 2
    assert 0x80 == a
    assert StatusRegister.sign?(p)
  end

  test "adc generic sets zero" do
    %CPU{registers: %{p: p, a: a}} = execute [0x69, 0xFF, 0x69, 0x01], 2
    assert 0x00 == a
    assert StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "adc generic sets overflow" do
    %CPU{registers: %{p: p, a: a}} = execute [0x69, 0x7F, 0x69, 0x01], 2
    assert 0x80 == a
    assert StatusRegister.overflow?(p)
  end

  test "and generic" do
    cpu = %CPU{registers: registers} = CPU.new([0x25, 0x02, 0xFF])
    cpu = %CPU{cpu | registers: %{registers | a: 0x01}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert 0x01 == a
    assert not StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "and generic with immediate" do
    cpu = %CPU{registers: registers} = CPU.new([0x29, 0xFF])
    cpu = %CPU{cpu | registers: %{registers | a: 0x01}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert 0x01 == a
    assert not StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "and generic can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0x25, 0x02, 0xFF])
    cpu = %CPU{cpu | registers: %{registers | a: 0x00}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert 0x00 == a
    assert StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "and generic can set sign" do
    cpu = %CPU{registers: registers} = CPU.new([0x25, 0x02, 0xFF])
    cpu = %CPU{cpu | registers: %{registers | a: 0x80}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert 0x80 == a
    assert not StatusRegister.zero?(p)
    assert StatusRegister.sign?(p)
  end

  test "bit generic can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0x24, 0x02, 0x00])
    cpu = %CPU{cpu | registers: %{registers | a: 0xFF}}
    %CPU{registers: %{p: p}} = execute cpu
    assert StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.overflow?(p)
  end

  test "bit generic can set sign and overflow" do
    cpu = %CPU{registers: registers} = CPU.new([0x24, 0x02, 0xC0])
    cpu = %CPU{cpu | registers: %{registers | a: 0xFF}}
    %CPU{registers: %{p: p}} = execute cpu
    assert not StatusRegister.zero?(p)
    assert StatusRegister.sign?(p)
    assert StatusRegister.overflow?(p)
  end

  test "cmp generic" do
    cpu = %CPU{registers: registers} = CPU.new([0xC5, 0x02, 0x18])
    cpu = %CPU{cpu | registers: %{registers | a: 0xF6}}
    %CPU{registers: %{p: p}} = execute cpu
    assert StatusRegister.carry?(p)
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "cmp generic with immediate" do
    cpu = %CPU{registers: registers} = CPU.new([0xC9, 0x18])
    cpu = %CPU{cpu | registers: %{registers | a: 0xF6}}
    %CPU{registers: %{p: p}} = execute cpu
    assert StatusRegister.carry?(p)
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "cmp generic can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0xC5, 0x02, 0x18])
    cpu = %CPU{cpu | registers: %{registers | a: 0x18}}
    %CPU{registers: %{p: p}} = execute cpu
    assert StatusRegister.carry?(p)
    assert not StatusRegister.sign?(p)
    assert StatusRegister.zero?(p)
  end

  test "cmp generic can set carry" do
    cpu = %CPU{registers: registers} = CPU.new([0xC5, 0x02, 0xF6])
    cpu = %CPU{cpu | registers: %{registers | a: 0x18}}
    %CPU{registers: %{p: p}} = execute cpu
    assert not StatusRegister.carry?(p)
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "eor generic" do
    cpu = %CPU{registers: registers} = CPU.new([0x45, 0x02, 0x80])
    cpu = %CPU{cpu | registers: %{registers | a: 0x81}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert 0x01 == a
    assert not StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "eor generic with immediate" do
    cpu = %CPU{registers: registers} = CPU.new([0x49, 0x80])
    cpu = %CPU{cpu | registers: %{registers | a: 0x81}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert 0x01 == a
    assert not StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "eor generic can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0x45, 0x02, 0x80])
    cpu = %CPU{cpu | registers: %{registers | a: 0x80}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert 0x00 == a
    assert StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "eor generic can set sign" do
    cpu = %CPU{registers: registers} = CPU.new([0x45, 0x02, 0xC0])
    cpu = %CPU{cpu | registers: %{registers | a: 0x40}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert 0x80 == a
    assert not StatusRegister.zero?(p)
    assert StatusRegister.sign?(p)
  end

  test "ora generic" do
    cpu = %CPU{registers: registers} = CPU.new([0x05, 0x02, 0x80])
    cpu = %CPU{cpu | registers: %{registers | a: 0x81}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert 0x81 == a
    assert not StatusRegister.zero?(p)
    assert StatusRegister.sign?(p)
  end

  test "ora generic with immediate" do
    cpu = %CPU{registers: registers} = CPU.new([0x05, 0x80])
    cpu = %CPU{cpu | registers: %{registers | a: 0x81}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert 0x81 == a
    assert not StatusRegister.zero?(p)
    assert StatusRegister.sign?(p)
  end

  test "sbc generic" do
    cpu = %CPU{registers: registers} = CPU.new([0xE5, 0x02, 0x10])
    cpu = %CPU{cpu | registers: %{registers | a: 0x15, p: 0xFF}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert 0x05 == a
    assert not StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.overflow?(p)
    assert StatusRegister.carry?(p)
  end

  test "sbc generic with immediate" do
    cpu = %CPU{registers: registers} = CPU.new([0xE9, 0x10])
    cpu = %CPU{cpu | registers: %{registers | a: 0x15, p: 0xFF}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert 0x05 == a
    assert not StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.overflow?(p)
    assert StatusRegister.carry?(p)
  end

  test "sbc generic can set carry" do
    cpu = %CPU{registers: registers} = CPU.new([0xE5, 0x02, 0x15])
    cpu = %CPU{cpu | registers: %{registers | a: 0x10, p: 0xFF}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert 251 == a
    assert not StatusRegister.zero?(p)
    assert StatusRegister.sign?(p)
    assert not StatusRegister.overflow?(p)
    assert not StatusRegister.carry?(p)
  end

  test "sbc generic can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0xE5, 0x02, 0x00])
    cpu = %CPU{cpu | registers: %{registers | a: 0x00, p: 0xFF}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert 0x00 == a
    assert StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.overflow?(p)
    assert StatusRegister.carry?(p)
  end

  test "sbc generic can set overflow" do
    cpu = %CPU{registers: registers} = CPU.new([0xE5, 0x02, -126])
    cpu = %CPU{cpu | registers: %{registers | a: 126, p: 0xFF}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert 252 == a
    assert not StatusRegister.zero?(p)
    assert StatusRegister.sign?(p)
    assert StatusRegister.overflow?(p)
    assert not StatusRegister.carry?(p)
  end

  test "inc generic" do
    %CPU{memory: memory, registers: %{p: p}} = execute [0xE6, 0x02, 0x05]
    assert 0x06 == Memory.peek(memory, 0x02)
    assert not StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "inc generic can set zero" do
    %CPU{memory: memory, registers: %{p: p}} = execute [0xE6, 0x02, 0xFF]
    assert 0x00 == Memory.peek(memory, 0x02)
    assert StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "inc generic can set sign" do
    %CPU{memory: memory, registers: %{p: p}} = execute [0xE6, 0x02, 0x7F]
    assert 0x80 == Memory.peek(memory, 0x02)
    assert not StatusRegister.zero?(p)
    assert StatusRegister.sign?(p)
  end

  test "dec generic" do
    %CPU{memory: memory, registers: %{p: p}} = execute [0xC6, 0x02, 0x06]
    assert 0x05 == Memory.peek(memory, 0x02)
    assert not StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "dec generic can set zero" do
    %CPU{memory: memory, registers: %{p: p}} = execute [0xC6, 0x02, 0x01]
    assert 0x00 == Memory.peek(memory, 0x02)
    assert StatusRegister.zero?(p)
    assert not StatusRegister.sign?(p)
  end

  test "dec generic can set sign" do
    %CPU{memory: memory, registers: %{p: p}} = execute [0xC6, 0x02, 0x00]
    assert 0xFF == Memory.peek(memory, 0x02)
    assert not StatusRegister.zero?(p)
    assert StatusRegister.sign?(p)
  end

  test "cpx generic" do
    cpu = %CPU{registers: registers} = CPU.new([0xE4, 0x02, 0x18])
    cpu = %CPU{cpu | registers: %{registers | x: 0xF6}}
    %CPU{registers: %{p: p}} = execute cpu
    assert StatusRegister.carry?(p)
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "cpx generic with immediate" do
    cpu = %CPU{registers: registers} = CPU.new([0xE0, 0x18])
    cpu = %CPU{cpu | registers: %{registers | x: 0xF6}}
    %CPU{registers: %{p: p}} = execute cpu
    assert StatusRegister.carry?(p)
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "cpx generic can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0xE4, 0x02, 0x18])
    cpu = %CPU{cpu | registers: %{registers | x: 0x18}}
    %CPU{registers: %{p: p}} = execute cpu
    assert StatusRegister.carry?(p)
    assert not StatusRegister.sign?(p)
    assert StatusRegister.zero?(p)
  end

  test "cpx generic can set carry" do
    cpu = %CPU{registers: registers} = CPU.new([0xE4, 0x02, 0xF6])
    cpu = %CPU{cpu | registers: %{registers | x: 0x18}}
    %CPU{registers: %{p: p}} = execute cpu
    assert not StatusRegister.carry?(p)
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "cpy generic" do
    cpu = %CPU{registers: registers} = CPU.new([0xC4, 0x02, 0x18])
    cpu = %CPU{cpu | registers: %{registers | y: 0xF6}}
    %CPU{registers: %{p: p}} = execute cpu
    assert StatusRegister.carry?(p)
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "cpy generic with immediate" do
    cpu = %CPU{registers: registers} = CPU.new([0xC0, 0x18])
    cpu = %CPU{cpu | registers: %{registers | y: 0xF6}}
    %CPU{registers: %{p: p}} = execute cpu
    assert StatusRegister.carry?(p)
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "cpy generic can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0xC4, 0x02, 0x18])
    cpu = %CPU{cpu | registers: %{registers | y: 0x18}}
    %CPU{registers: %{p: p}} = execute cpu
    assert StatusRegister.carry?(p)
    assert not StatusRegister.sign?(p)
    assert StatusRegister.zero?(p)
  end

  test "cpy generic can set carry" do
    cpu = %CPU{registers: registers} = CPU.new([0xC4, 0x02, 0xF6])
    cpu = %CPU{cpu | registers: %{registers | y: 0x18}}
    %CPU{registers: %{p: p}} = execute cpu
    assert not StatusRegister.carry?(p)
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "jmp indirect" do
    cpu = %CPU{registers: registers, memory: memory} = CPU.new([0x6C, 0xFE, 0x56])
    Memory.poke memory, 0x56FF, 0xAB
    Memory.poke memory, 0x56FE, 0xCD

    Memory.poke memory, 0xABCD, 0xE8
    cpu = %CPU{cpu | registers: %{registers | p: 0x01}}
    %CPU{registers: %{x: x}} = execute cpu, 2
    assert x == 0x01
  end

  test "jmp indirect w/page boundary bug" do
    cpu = %CPU{registers: registers, memory: memory} = CPU.new([0x6C, 0xFF, 0x56])
    Memory.poke memory, 0x5600, 0xAB
    Memory.poke memory, 0x56FF, 0xCD

    Memory.poke memory, 0xABCD, 0xE8
    cpu = %CPU{cpu | registers: %{registers | p: 0x00}}
    %CPU{registers: %{x: x}} = execute cpu, 2
    assert x == 0x01
  end

  test "jmp direct" do
    cpu = %CPU{registers: registers, memory: memory} = CPU.new([0x4C, 0xCD, 0xAB])
    Memory.poke memory, 0xABCD, 0xE8
    cpu = %CPU{cpu | registers: %{registers | p: 0x01}}
    %CPU{registers: %{x: x}} = execute cpu, 2
    assert x == 0x01
  end

  test "bcc c=1" do
    cpu = %CPU{registers: registers} = CPU.new([0x90, 0x50])
    cpu = %CPU{cpu | registers: %{registers | p: 0x01}}
    %CPU{registers: %{pc: pc}} = execute cpu
    assert pc == 0x02
  end

  test "bcc c=0" do
    cpu = %CPU{registers: registers} = CPU.new([0x90, 0x50])
    cpu = %CPU{cpu | registers: %{registers | p: 0x00}}
    %CPU{registers: %{pc: pc}} = execute cpu
    assert pc == 0x52
  end

  test "bcc c=0 and negative" do
    cpu = %CPU{registers: registers} = CPU.new([0xE8, 0x90, 0xFD])
    cpu = %CPU{cpu | registers: %{registers | x: 0x00, p: 0b00000001, pc: 0x00}}
    %CPU{registers: %{x: x}} = execute cpu, 4
    assert x == 0x02
  end

  test "bcs c=0" do
    cpu = %CPU{registers: registers} = CPU.new([0xB0, 0x50])
    cpu = %CPU{cpu | registers: %{registers | p: 0x00}}
    %CPU{registers: %{pc: pc}} = execute cpu
    assert pc == 0x02
  end

  test "bcs c=1" do
    cpu = %CPU{registers: registers} = CPU.new([0xB0, 0x50])
    cpu = %CPU{cpu | registers: %{registers | p: 0x01}}
    %CPU{registers: %{pc: pc}} = execute cpu
    assert pc == 0x52
  end

  test "bcs c=1 and negative" do
    cpu = %CPU{registers: registers} = CPU.new([0xE8, 0xB0, 0xFD])
    cpu = %CPU{cpu | registers: %{registers | x: 0xFF, p: 0b00000001, pc: 0x01}}
    %CPU{registers: %{x: x}} = execute cpu, 4
    assert x == 0x01
  end

  test "beq z=0" do
    cpu = %CPU{registers: registers} = CPU.new([0xF0, 0x50])
    cpu = %CPU{cpu | registers: %{registers | p: 0x00}}
    %CPU{registers: %{pc: pc}} = execute cpu
    assert pc == 0x02
  end

  test "beq z=1" do
    cpu = %CPU{registers: registers} = CPU.new([0xF0, 0x50])
    cpu = %CPU{cpu | registers: %{registers | p: 0x02}}
    %CPU{registers: %{pc: pc}} = execute cpu
    assert pc == 0x52
  end

  test "beq z=1 and negative" do
    cpu = %CPU{registers: registers} = CPU.new([0xE8, 0xF0, 0xFD])
    cpu = %CPU{cpu | registers: %{registers | x: 0xFF, p: 0b00000010, pc: 0x01}}
    %CPU{registers: %{x: x}} = execute cpu, 4
    assert x == 0x01
  end

  test "bmi s=0" do
    cpu = %CPU{registers: registers} = CPU.new([0x30, 0x50])
    cpu = %CPU{cpu | registers: %{registers | p: 0x00}}
    %CPU{registers: %{pc: pc}} = execute cpu
    assert pc == 0x02
  end

  test "bmi s=1" do
    cpu = %CPU{registers: registers} = CPU.new([0x30, 0x50])
    cpu = %CPU{cpu | registers: %{registers | p: 0b10000000}}
    %CPU{registers: %{pc: pc}} = execute cpu
    assert pc == 0x52
  end

  test "bmi s=1 and negative" do
    cpu = %CPU{registers: registers} = CPU.new([0xE8, 0x30, 0xFD])
    cpu = %CPU{cpu | registers: %{registers | x: 0xF0, p: 0x00, pc: 0b100000000}}
    %CPU{registers: %{x: x}} = execute cpu, 4
    assert x == 0xF2
  end

  test "bne z=1" do
    cpu = %CPU{registers: registers} = CPU.new([0xD0, 0x50])
    cpu = %CPU{cpu | registers: %{registers | p: 0x02}}
    %CPU{registers: %{pc: pc}} = execute cpu
    assert pc == 0x02
  end

  test "bne z=0" do
    cpu = %CPU{registers: registers} = CPU.new([0xD0, 0x50])
    cpu = %CPU{cpu | registers: %{registers | p: 0x00}}
    %CPU{registers: %{pc: pc}} = execute cpu
    assert pc == 0x52
  end

  test "bne z=0 and negative" do
    cpu = %CPU{registers: registers} = CPU.new([0xE8, 0xD0, 0xFD])
    cpu = %CPU{cpu | registers: %{registers | x: 0x00, p: 0b00000000, pc: 0x01}}
    %CPU{registers: %{x: x}} = execute cpu, 4
    assert x == 0x02
  end

  test "bpl s=1" do
    cpu = %CPU{registers: registers} = CPU.new([0x10, 0x50])
    cpu = %CPU{cpu | registers: %{registers | p: 0b10000000}}
    %CPU{registers: %{pc: pc}} = execute cpu
    assert pc == 0x02
  end

  test "bpl s=0" do
    cpu = %CPU{registers: registers} = CPU.new([0x10, 0x50])
    cpu = %CPU{cpu | registers: %{registers | p: 0x00}}
    %CPU{registers: %{pc: pc}} = execute cpu
    assert pc == 0x52
  end

  test "bpl s=0 and negative" do
    cpu = %CPU{registers: registers} = CPU.new([0xE8, 0x10, 0xFD])
    cpu = %CPU{cpu | registers: %{registers | x: 0x00, p: 0x00, pc: 0x01}}
    %CPU{registers: %{x: x}} = execute cpu, 4
    assert x == 0x02
  end

  test "bvc v=1" do
    cpu = %CPU{registers: registers} = CPU.new([0x50, 0x50])
    cpu = %CPU{cpu | registers: %{registers | p: 0b01000000}}
    %CPU{registers: %{pc: pc}} = execute cpu
    assert pc == 0x02
  end

  test "bvc v=0" do
    cpu = %CPU{registers: registers} = CPU.new([0x50, 0x50])
    cpu = %CPU{cpu | registers: %{registers | p: 0b00000000}}
    %CPU{registers: %{pc: pc}} = execute cpu
    assert pc == 0x52
  end

  test "bvc v=0 and negative" do
    cpu = %CPU{registers: registers} = CPU.new([0xE8, 0x50, 0xFD])
    cpu = %CPU{cpu | registers: %{registers | p: 0b00000000, pc: 0x01}}
    %CPU{registers: %{x: x}} = execute cpu, 4
    assert x == 0x02
  end

  test "bvs v=0" do
    cpu = %CPU{registers: registers} = CPU.new([0x70, 0x50])
    cpu = %CPU{cpu | registers: %{registers | p: 0x00}}
    %CPU{registers: %{pc: pc}} = execute cpu
    assert pc == 0x02
  end

  test "bvs v=1" do
    cpu = %CPU{registers: registers} = CPU.new([0x70, 0x50])
    cpu = %CPU{cpu | registers: %{registers | p: 0b01000000}}
    %CPU{registers: %{pc: pc}} = execute cpu
    assert pc == 0x52
  end

  test "bvs v=1 and negative" do
    cpu = %CPU{registers: registers} = CPU.new([0xE8, 0x70, 0xFD])
    cpu = %CPU{cpu | registers: %{registers | p: 0b01000000, pc: 0x01}}
    %CPU{registers: %{x: x}} = execute cpu, 4
    assert x == 0x02
  end

  test "jsr and rts" do
    cpu = %CPU{memory: memory, registers: registers} = CPU.new([])
    cpu = %CPU{cpu | registers: %{registers | pc: 0xABCD}}
    Memory.poke memory, 0xABCD, 0xE8
    Memory.poke memory, 0xABCE, 0xE8

    Memory.poke memory, 0xABCF, 0x20
    Memory.poke memory, 0xABD0, 0x56
    Memory.poke memory, 0xABD1, 0x55

    Memory.poke memory, 0x5556, 0xC8
    Memory.poke memory, 0x5557, 0xC8
    Memory.poke memory, 0x5558, 0x60

    Memory.poke memory, 0xABD2, 0xE8
    Memory.poke memory, 0xABD3, 0xE8

    %CPU{registers: %{x: x, y: y}} = execute cpu, 8
    assert x == 0x04
    assert y == 0x02
  end

  test "rts" do
    cpu = %CPU{memory: memory} = CPU.new([0x60])
    Memory.poke memory, 0x0100, 0xCD
    Memory.poke memory, 0x0101, 0xAB
    %CPU{registers: %{pc: pc, sp: sp}} = execute cpu
    assert pc == 0xABCE
    assert sp == 0x01
  end

  test "tax" do
    cpu = %CPU{registers: registers} = CPU.new([0xAA])
    cpu = %CPU{cpu | registers: %{registers | a: 0x05, x: 0x18}}
    %CPU{registers: %{x: x, p: p}} = execute cpu
    assert x == 0x05
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "tax can set sign" do
    cpu = %CPU{registers: registers} = CPU.new([0xAA])
    cpu = %CPU{cpu | registers: %{registers | a: 0xFF, x: 0x00}}
    %CPU{registers: %{x: x, p: p}} = execute cpu
    assert x == 0xFF
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "tax can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0xAA])
    cpu = %CPU{cpu | registers: %{registers | x: 0xFF, a: 0x00}}
    %CPU{registers: %{x: x, p: p}} = execute cpu
    assert x == 0x00
    assert not StatusRegister.sign?(p)
    assert StatusRegister.zero?(p)
  end

  test "txa" do
    cpu = %CPU{registers: registers} = CPU.new([0x8A])
    cpu = %CPU{cpu | registers: %{registers | x: 0x05, a: 0x18}}
    %CPU{registers: %{a: a, p: p}} = execute cpu
    assert a == 0x05
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "txa can set sign" do
    cpu = %CPU{registers: registers} = CPU.new([0x8A])
    cpu = %CPU{cpu | registers: %{registers | x: 0xFF, a: 0x00}}
    %CPU{registers: %{a: a, p: p}} = execute cpu
    assert a == 0xFF
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "txa can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0x8A])
    cpu = %CPU{cpu | registers: %{registers | a: 0xFF, x: 0x00}}
    %CPU{registers: %{a: a, p: p}} = execute cpu
    assert a == 0x00
    assert not StatusRegister.sign?(p)
    assert StatusRegister.zero?(p)
  end

  test "tay" do
    cpu = %CPU{registers: registers} = CPU.new([0xA8])
    cpu = %CPU{cpu | registers: %{registers | a: 0x05, y: 0x18}}
    %CPU{registers: %{y: y, p: p}} = execute cpu
    assert y == 0x05
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "tay can set sign" do
    cpu = %CPU{registers: registers} = CPU.new([0xA8])
    cpu = %CPU{cpu | registers: %{registers | a: 0xFF, y: 0x00}}
    %CPU{registers: %{y: y, p: p}} = execute cpu
    assert y == 0xFF
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "tay can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0xA8])
    cpu = %CPU{cpu | registers: %{registers | y: 0xFF, a: 0x00}}
    %CPU{registers: %{y: y, p: p}} = execute cpu
    assert y == 0x00
    assert not StatusRegister.sign?(p)
    assert StatusRegister.zero?(p)
  end

  test "tya" do
    cpu = %CPU{registers: registers} = CPU.new([0x98])
    cpu = %CPU{cpu | registers: %{registers | y: 0x05, a: 0x18}}
    %CPU{registers: %{a: a, p: p}} = execute cpu
    assert a == 0x05
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "tya can set sign" do
    cpu = %CPU{registers: registers} = CPU.new([0x98])
    cpu = %CPU{cpu | registers: %{registers | y: 0xFF, a: 0x00}}
    %CPU{registers: %{a: a, p: p}} = execute cpu
    assert a == 0xFF
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "tya can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0x98])
    cpu = %CPU{cpu | registers: %{registers | a: 0xFF, y: 0x00}}
    %CPU{registers: %{a: a, p: p}} = execute cpu
    assert a == 0x00
    assert not StatusRegister.sign?(p)
    assert StatusRegister.zero?(p)
  end

  test "tsx" do
    cpu = %CPU{registers: registers} = CPU.new([0xBA])
    cpu = %CPU{cpu | registers: %{registers | x: 0x05, sp: 0x18}}
    %CPU{registers: %{x: x, p: p}} = execute cpu
    assert x == 0x18
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "tsx can set sign" do
    cpu = %CPU{registers: registers} = CPU.new([0xBA])
    cpu = %CPU{cpu | registers: %{registers | x: 0x05, sp: 0xFF}}
    %CPU{registers: %{x: x, p: p}} = execute cpu
    assert x == 0xFF
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "tsx can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0xBA])
    cpu = %CPU{cpu | registers: %{registers | x: 0xFF, sp: 0x00}}
    %CPU{registers: %{x: x, p: p}} = execute cpu
    assert x == 0x00
    assert not StatusRegister.sign?(p)
    assert StatusRegister.zero?(p)
  end

  test "txs" do
    cpu = %CPU{registers: registers} = CPU.new([0x9A])
    cpu = %CPU{cpu | registers: %{registers | x: 0x05, sp: 0x88}}
    %CPU{registers: %{sp: sp}} = execute cpu
    assert sp == 0x05
  end

  test "dex" do
    cpu = %CPU{registers: registers} = CPU.new([0xCA])
    cpu = %CPU{cpu | registers: %{registers | x: 0x05}}
    %CPU{registers: %{p: p, x: x}} = execute cpu
    assert x == 0x04
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "dex can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0xCA])
    cpu = %CPU{cpu | registers: %{registers | x: 0x01}}
    %CPU{registers: %{p: p, x: x}} = execute cpu
    assert x == 0x00
    assert not StatusRegister.sign?(p)
    assert StatusRegister.zero?(p)
  end

  test "dex can set sign" do
    cpu = %CPU{registers: registers} = CPU.new([0xCA])
    cpu = %CPU{cpu | registers: %{registers | x: 0x00}}
    %CPU{registers: %{p: p, x: x}} = execute cpu
    assert x == 0xFF
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "dey" do
    cpu = %CPU{registers: registers} = CPU.new([0x88])
    cpu = %CPU{cpu | registers: %{registers | y: 0x05}}
    %CPU{registers: %{p: p, y: y}} = execute cpu
    assert y == 0x04
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "dey can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0x88])
    cpu = %CPU{cpu | registers: %{registers | y: 0x01}}
    %CPU{registers: %{p: p, y: y}} = execute cpu
    assert y == 0x00
    assert not StatusRegister.sign?(p)
    assert StatusRegister.zero?(p)
  end

  test "dey can set sign" do
    cpu = %CPU{registers: registers} = CPU.new([0x88])
    cpu = %CPU{cpu | registers: %{registers | y: 0x00}}
    %CPU{registers: %{p: p, y: y}} = execute cpu
    assert y == 0xFF
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "inx" do
    cpu = %CPU{registers: registers} = CPU.new([0xE8])
    cpu = %CPU{cpu | registers: %{registers | x: 0x05}}
    %CPU{registers: %{p: p, x: x}} = execute cpu
    assert x == 0x06
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "inx can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0xE8])
    cpu = %CPU{cpu | registers: %{registers | x: 0xFF}}
    %CPU{registers: %{p: p, x: x}} = execute cpu
    assert x == 0x00
    assert not StatusRegister.sign?(p)
    assert StatusRegister.zero?(p)
  end

  test "inx can set sign" do
    cpu = %CPU{registers: registers} = CPU.new([0xE8])
    cpu = %CPU{cpu | registers: %{registers | x: 0x7F}}
    %CPU{registers: %{p: p, x: x}} = execute cpu
    assert x == 0x80
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "iny" do
    cpu = %CPU{registers: registers} = CPU.new([0xC8])
    cpu = %CPU{cpu | registers: %{registers | y: 0x05}}
    %CPU{registers: %{p: p, y: y}} = execute cpu
    assert y == 0x06
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "iny can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0xC8])
    cpu = %CPU{cpu | registers: %{registers | y: 0xFF}}
    %CPU{registers: %{p: p, y: y}} = execute cpu
    assert y == 0x00
    assert not StatusRegister.sign?(p)
    assert StatusRegister.zero?(p)
  end

  test "iny can set sign" do
    cpu = %CPU{registers: registers} = CPU.new([0xC8])
    cpu = %CPU{cpu | registers: %{registers | y: 0x7F}}
    %CPU{registers: %{p: p, y: y}} = execute cpu
    assert y == 0x80
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "rol" do
    cpu = %CPU{registers: registers} = CPU.new([0x2A])
    cpu = %CPU{cpu | registers: %{registers | a: 0b01110001}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert a == 0b11100010
    assert not StatusRegister.carry?(p)
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "rol with mem" do
    cpu = %CPU{memory: memory} = CPU.new([0x26, 0x02, 0b01110001])
    %CPU{registers: %{p: p}} = execute cpu
    assert Memory.peek(memory, 0x02) == 0b11100010
    assert not StatusRegister.carry?(p)
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "rol can set carry" do
    cpu = %CPU{registers: registers} = CPU.new([0x2A])
    cpu = %CPU{cpu | registers: %{registers | a: 0b11110000}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert a == 0b11100001
    assert StatusRegister.carry?(p)
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "rol can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0x6A])
    cpu = %CPU{cpu | registers: %{registers | a: 0b0000000}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert a == 0x00
    assert not StatusRegister.carry?(p)
    assert not StatusRegister.sign?(p)
    assert StatusRegister.zero?(p)
  end

  test "ror" do
    cpu = %CPU{registers: registers} = CPU.new([0x6A])
    cpu = %CPU{cpu | registers: %{registers | a: 0b01110001}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert a == 0b10111000
    assert StatusRegister.carry?(p)
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "ror with mem" do
    cpu = %CPU{memory: memory} = CPU.new([0x66, 0x02, 0b01110001])
    %CPU{registers: %{p: p}} = execute cpu
    assert Memory.peek(memory, 0x02) == 0b10111000
    assert StatusRegister.carry?(p)
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "ror can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0x6A])
    cpu = %CPU{cpu | registers: %{registers | a: 0b0000000}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert a == 0x00
    assert not StatusRegister.carry?(p)
    assert not StatusRegister.sign?(p)
    assert StatusRegister.zero?(p)
  end

  test "asl" do
    cpu = %CPU{registers: registers} = CPU.new([0x0A])
    cpu = %CPU{cpu | registers: %{registers | a: 0b11110000}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert a == 0b11100000
    assert StatusRegister.carry?(p)
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "asl with mem" do
    cpu = %CPU{memory: memory} = CPU.new([0x06, 0x02, 0b11110000])
    %CPU{registers: %{p: p}} = execute cpu
    assert Memory.peek(memory, 0x02) == 0b11100000
    assert StatusRegister.carry?(p)
    assert StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "asl can set zero and carry" do
    cpu = %CPU{registers: registers} = CPU.new([0x0A])
    cpu = %CPU{cpu | registers: %{registers | a: 0b10000000}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert a == 0b00000000
    assert StatusRegister.carry?(p)
    assert not StatusRegister.sign?(p)
    assert StatusRegister.zero?(p)
  end

  test "lsr with mem" do
    cpu = %CPU{memory: memory} = CPU.new([0x46, 0x02, 0b11110000])
    %CPU{registers: %{p: p}} = execute cpu
    assert Memory.peek(memory, 0x02) == 0b01111000
    assert not StatusRegister.carry?(p)
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "lsr" do
    cpu = %CPU{registers: registers} = CPU.new([0x4A])
    cpu = %CPU{cpu | registers: %{registers | a: 0b11110000}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert a == 0b01111000
    assert not StatusRegister.carry?(p)
    assert not StatusRegister.sign?(p)
    assert not StatusRegister.zero?(p)
  end

  test "lsr can set zero and carry" do
    cpu = %CPU{registers: registers} = CPU.new([0x4A])
    cpu = %CPU{cpu | registers: %{registers | a: 0b00000001}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert a == 0x00
    assert StatusRegister.carry?(p)
    assert not StatusRegister.sign?(p)
    assert StatusRegister.zero?(p)
  end

  test "pha" do
    cpu = %CPU{registers: registers, memory: memory} = CPU.new([0x48])
    cpu = %CPU{cpu | registers: %{registers | a: 0b11110000}}
    execute cpu
    assert Memory.peek(memory, 0x01FF) == 0b11110000
  end

  test "pla can set sign" do
    cpu = %CPU{registers: registers, memory: memory} = CPU.new([0x68])
    Memory.poke memory, 0x0100, 0b11110000
    cpu = %CPU{cpu | registers: %{registers | p: 0x00}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert a == 0b11110000
    assert StatusRegister.sign?(p)
  end

  test "pla can set zero" do
    cpu = %CPU{registers: registers} = CPU.new([0x68])
    cpu = %CPU{cpu | registers: %{registers | p: 0x00, a: 0xFF}}
    %CPU{registers: %{p: p, a: a}} = execute cpu
    assert a == 0x00
    assert StatusRegister.zero?(p)
  end

  test "php" do
    cpu = %CPU{registers: registers, memory: memory} = CPU.new([0x08])
    cpu = %CPU{cpu | registers: %{registers | p: 0b11110000}}
    execute cpu
    assert Memory.peek(memory, 0x01FF) == 0b11110000
  end

  test "plp" do
    cpu = %CPU{registers: registers, memory: memory} = CPU.new([0x28])
    Memory.poke memory, 0x0100, 0b11110000
    cpu = %CPU{cpu | registers: %{registers | p: 0xFF}}
    %CPU{registers: %{p: p}} = execute cpu
    assert p == 0b11110000
  end

  test "cli" do
    cpu = %CPU{registers: registers} = CPU.new([0x58])
    cpu = %CPU{cpu | registers: %{registers | p: 0xFF}}
    %CPU{registers: %{p: p}} = execute cpu
    assert not StatusRegister.interrupt_disable?(p)
  end

  test "sei" do
    cpu = %CPU{registers: registers} = CPU.new([0x78])
    cpu = %CPU{cpu | registers: %{registers | p: 0x00}}
    %CPU{registers: %{p: p}} = execute cpu
    assert StatusRegister.interrupt_disable?(p)
  end

  test "rti" do
    cpu = %CPU{memory: memory, registers: registers} = CPU.new([0x00])
    new_registers = %{registers | pc: 0x5566, p: 0b10101010}
    cpu = %CPU{cpu | registers: new_registers}
    Memory.poke memory, 0xFFFF, 0xAB
    Memory.poke memory, 0xFFFE, 0xCD
    Memory.poke memory, 0xABCD, 0x40

    %CPU{registers: %{p: p, pc: pc, sp: sp}} = execute cpu, 2
    assert pc == 0x5568
    assert sp == 0xFF
    assert p == 0b10101010
  end

  test "brk" do
    cpu = %CPU{memory: memory} = CPU.new([0x00])
    Memory.poke memory, 0xFFFF, 0xAB
    Memory.poke memory, 0xFFFE, 0xCD
    %CPU{registers: %{p: p, pc: pc, sp: sp}} = execute cpu
    assert StatusRegister.interrupt_disable?(p)
    assert StatusRegister.break?(p)
    assert Memory.peek(memory, 0x0100) == 0x00
    assert Memory.peek(memory, 0x0101) == 0x00
    assert pc == 0xABCD
    assert sp == 0xFC
  end

  test "clc" do
    cpu = %CPU{registers: registers} = CPU.new([0x18])
    cpu = %CPU{cpu | registers: %{registers | p: 0xFF}}
    %CPU{registers: %{p: p}} = execute cpu
    assert not StatusRegister.carry?(p)
  end

  test "sec" do
    cpu = %CPU{registers: registers} = CPU.new([0x38])
    cpu = %CPU{cpu | registers: %{registers | p: 0x00}}
    %CPU{registers: %{p: p}} = execute cpu
    assert StatusRegister.carry?(p)
  end

  test "cld" do
    cpu = %CPU{registers: registers} = CPU.new([0xD8])
    cpu = %CPU{cpu | registers: %{registers | p: 0xFF}}
    %CPU{registers: %{p: p}} = execute cpu
    assert not StatusRegister.decimal_mode?(p)
  end

  test "sed" do
    cpu = %CPU{registers: registers} = CPU.new([0xF8])
    cpu = %CPU{cpu | registers: %{registers | p: 0x00}}
    %CPU{registers: %{p: p}} = execute cpu
    assert StatusRegister.decimal_mode?(p)
  end

  test "clv" do
    cpu = %CPU{registers: registers} = CPU.new([0xB8])
    cpu = %CPU{cpu | registers: %{registers | p: 0xFF}}
    %CPU{registers: %{p: p}} = execute cpu
    assert not StatusRegister.overflow?(p)
  end

  test "nop" do
    execute [0xEA]
  end

  defp execute(_, steps \\ 1)
  defp execute(%CPU{} = cpu, steps) do
    Enum.reduce 1..steps, cpu, fn(_, cpu2) -> CPU.next cpu2 end
  end

  defp execute(bytes, steps) do
    Enum.reduce 1..steps, CPU.new(bytes), fn(_, cpu) -> CPU.next cpu end
  end
end
