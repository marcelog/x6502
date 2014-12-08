defmodule X6502.EU do
  require Logger
  use Bitwise

  @pc_changed_by %{
    brk: true,
    jsr: true,
    rts: true,
    rti: true,
    bvs: true,
    bvc: true,
    bpl: true,
    bne: true,
    bmi: true,
    beq: true,
    bcs: true,
    bcc: true,
    jmp: true,
    jmp_indirect: true
  }

  alias X6502.AU, as: AU
  alias X6502.CPU, as: CPU
  alias X6502.ALU, as: ALU
  alias X6502.StatusRegister, as: StatusRegister

  def execute(instruction = %{mnemonic: mnemonic, bytes: bytes}, state) do
    %X6502.CPU{registers: registers} = state
    operand_location = AU.address instruction[:mode], state
    pc_fmt = :io_lib.format "0x~4.16.0B", [registers[:pc]]
    Logger.debug 'Executing PC: #{pc_fmt}: #{mnemonic}, #{instruction[:mode]} with operand at #{operand_location} with registers: #{inspect registers}'
    state = %CPU{registers: registers = %{pc: pc}} = real_execute(
      instruction, operand_location, state
    )
    pc = case @pc_changed_by[mnemonic] do
      true -> pc
      _ -> inc_pc pc, bytes
    end
    pc_fmt = :io_lib.format '0x~4.16.0B', [pc]
    Logger.debug 'Result pc at: #{pc_fmt}: #{inspect registers}'
    %CPU{state | registers: %{registers | pc: pc}}
  end

  defp real_execute(
    %{mnemonic: :lda},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p
      }
    }
  ) do
    a = mm.peek memory, operand_location
    p = set_sign p, a
    p = set_zero p, a
    registers = %{registers | a: a, p: p}
    %CPU{state | registers: registers}
  end

  defp real_execute(
    %{mnemonic: :sta},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: %{
        a: a
      }
    }
  ) do
    mm.poke memory, operand_location, a
    state
  end

  defp real_execute(
    %{mnemonic: :ldx},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p
      }
    }
  ) do
    x = mm.peek memory, operand_location
    p = set_sign p, x
    p = set_zero p, x
    registers = %{registers | x: x, p: p}
    %CPU{state | registers: registers}
  end

  defp real_execute(
    %{mnemonic: :stx},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: %{
        x: x
      }
    }
  ) do
    mm.poke memory, operand_location, x
    state
  end

  defp real_execute(
    %{mnemonic: :ldy},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p
      }
    }
  ) do
    y = mm.peek memory, operand_location
    p = set_sign p, y
    p = set_zero p, y
    registers = %{registers | y: y, p: p}
    %CPU{state | registers: registers}
  end

  defp real_execute(
    %{mnemonic: :sty},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: %{
        y: y
      }
    }
  ) do
    mm.poke memory, operand_location, y
    state
  end

  defp real_execute(
    %{mnemonic: :adc},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        a: a,
        p: p
      }
    }
  ) do
    operand = mm.peek memory, operand_location
    carry = StatusRegister.carry_value p
    {new_carry, new_overflow, result} = ALU.adc a, operand, carry
    a = result
    p = set_sign p, a
    p = set_zero p, a
    p = StatusRegister.set_overflow p, new_overflow
    p = StatusRegister.set_carry p, new_carry
    %CPU{state | registers: %{registers | p: p, a: a}}
  end

  defp real_execute(
    %{mnemonic: :and},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        a: a,
        p: p
      }
    }
  ) do
    a = a &&& mm.peek(memory, operand_location)
    p = set_sign p, a
    p = set_zero p, a
    %CPU{state | registers: %{registers | p: p, a: a}}
  end

  defp real_execute(
    %{mnemonic: :bit},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        a: a,
        p: p
      }
    }
  ) do
    operand = mm.peek memory, operand_location
    result = a &&& operand
    p = set_zero p, result
    p = set_sign p, operand
    p = set_overflow p, operand
    %CPU{state | registers: %{registers | p: p}}
  end

  defp real_execute(
    %{mnemonic: :cmp},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        a: a,
        p: p
      }
    }
  ) do
    operand_bin = mm.peek memory, operand_location
    {new_carry, _, result} = ALU.sbc a, operand_bin
    p = StatusRegister.set_carry p, new_carry
    p = set_sign p, result
    p = set_zero p, result
    %CPU{state | registers: %{registers | p: p}}
  end

  defp real_execute(
    %{mnemonic: :eor},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        a: a,
        p: p
      }
    }
  ) do
    a = a ^^^ mm.peek(memory, operand_location)
    p = set_sign p, a
    p = set_zero p, a
    %CPU{state | registers: %{registers | p: p, a: a}}
  end

  defp real_execute(
    %{mnemonic: :ora},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        a: a,
        p: p
      }
    }
  ) do
    a = a ||| mm.peek(memory, operand_location)
    p = set_sign p, a
    p = set_zero p, a
    %CPU{state | registers: %{registers | p: p, a: a}}
  end

  defp real_execute(
    %{mnemonic: :sbc},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        a: a,
        p: p
      }
    }
  ) do
    carry = StatusRegister.carry_value p
    operand = mm.peek memory, operand_location
    {new_carry, new_overflow, result} = ALU.sbc a, operand, carry
    a = result
    p = set_sign p, a
    p = set_zero p, a
    p = StatusRegister.set_overflow p, new_overflow
    p = StatusRegister.set_carry p, new_carry
    %CPU{state | registers: %{registers | p: p, a: a}}
  end

  defp real_execute(
    %{mnemonic: :inc},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p
      }
    }
  ) do
    operand = mm.peek memory, operand_location
    result = (operand + 1) &&& 0xFF
    p = set_sign p, result
    p = set_zero p, result
    mm.poke memory, operand_location, result
    %CPU{state | registers: %{registers | p: p}}
  end

  defp real_execute(
    %{mnemonic: :dec},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p
      }
    }
  ) do
    operand = mm.peek memory, operand_location
    result = (operand - 1) &&& 0xFF
    p = set_sign p, result
    p = set_zero p, result
    mm.poke memory, operand_location, result
    %CPU{state | registers: %{registers | p: p}}
  end

  defp real_execute(
    %{mnemonic: :cpx},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        x: x,
        p: p
      }
    }
  ) do
    operand = mm.peek memory, operand_location
    {new_carry, _, result} = ALU.sbc x, operand
    p = StatusRegister.set_carry p, new_carry
    p = set_sign p, result
    p = set_zero p, result
    %CPU{state | registers: %{registers | p: p}}
  end

  defp real_execute(
    %{mnemonic: :cpy},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        y: y,
        p: p
      }
    }
  ) do
    operand = mm.peek memory, operand_location
    {new_carry, _, result} = ALU.sbc y, operand
    p = StatusRegister.set_carry p, new_carry
    p = set_sign p, result
    p = set_zero p, result
    %CPU{state | registers: %{registers | p: p}}
  end

  defp real_execute(
    %{mnemonic: :jmp_indirect},
    _operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        pc: pc
      }
    }
  ) do

    # http://en.wikipedia.org/wiki/MOS_Technology_6502#Bugs_and_quirks
    # The 6502's memory indirect jump instruction, JMP (<address>), is
    # partially broken. If <address> is hex xxFF (i.e., any word ending in FF),
    # the processor will not jump to the address stored in xxFF and xxFF+1 as
    # expected, but rather the one defined by xxFF and xx00 (for example,
    # JMP ($10FF) would jump to the address stored in 10FF and 1000, instead of
    # the one stored in 10FF and 1100). This defect continued through the
    # entire NMOS line, but was corrected in the CMOS derivatives.
    pc = inc_pc pc, 1
    pc_l = mm.peek memory, pc
    pre_pc_l = pc_l
    pc = inc_pc pc, 1
    pc_h = mm.peek memory, pc
    pc = X6502.AU.to_16bits pc_h, pc_l

    pc_l = mm.peek memory, pc
    pc_h = case pre_pc_l do
      0xFF -> mm.peek memory, (X6502.AU.to_16bits pc_h, 0x00)
      _ ->
        pc = inc_pc pc, 1
        mm.peek memory, pc
    end
    pc = X6502.AU.to_16bits pc_h, pc_l
    %CPU{state | registers: %{registers | pc: pc}}
  end

  defp real_execute(
    %{mnemonic: :jmp},
    _operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        pc: pc
      }
    }
  ) do

    pc = inc_pc pc, 1
    pc_l = mm.peek memory, pc
    pc = inc_pc pc, 1
    pc_h = mm.peek memory, pc

    pc = X6502.AU.to_16bits pc_h, pc_l
    %CPU{state | registers: %{registers | pc: pc}}
  end

  defp real_execute(
    %{mnemonic: :bcc},
    nil,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p,
        pc: pc
      }
    }
  ) do

    pc = inc_pc pc, 1
    disp = mm.peek memory, pc
    pc = inc_pc pc, 1

    pc_h = (pc >>> 8) &&& 0xFF
    pc_l = pc &&& 0xFF

    pc_l = if not StatusRegister.carry? p do
      X6502.AU.inc_address_8 pc_l, disp
    else
      pc_l
    end
    pc = X6502.AU.to_16bits pc_h, pc_l
    %CPU{state | registers: %{registers | pc: pc}}
  end

  defp real_execute(
    %{mnemonic: :bcs},
    nil,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p,
        pc: pc
      }
    }
  ) do

    pc = inc_pc pc, 1
    disp = mm.peek memory, pc
    pc = inc_pc pc, 1

    pc_h = (pc >>> 8) &&& 0xFF
    pc_l = pc &&& 0xFF

    pc_l = if StatusRegister.carry? p do
      X6502.AU.inc_address_8 pc_l, disp
    else
      pc_l
    end
    pc = X6502.AU.to_16bits pc_h, pc_l
    %CPU{state | registers: %{registers | pc: pc}}
  end

  defp real_execute(
    %{mnemonic: :beq},
    nil,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p,
        pc: pc
      }
    }
  ) do

    pc = inc_pc pc, 1
    disp = mm.peek memory, pc
    pc = inc_pc pc, 1

    pc_h = (pc >>> 8) &&& 0xFF
    pc_l = pc &&& 0xFF

    pc_l = if StatusRegister.zero? p do
      X6502.AU.inc_address_8 pc_l, disp
    else
      pc_l
    end
    pc = X6502.AU.to_16bits pc_h, pc_l
    %CPU{state | registers: %{registers | pc: pc}}
  end

  defp real_execute(
    %{mnemonic: :bmi},
    nil,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p,
        pc: pc
      }
    }
  ) do

    pc = inc_pc pc, 1
    disp = mm.peek memory, pc
    pc = inc_pc pc, 1

    pc_h = (pc >>> 8) &&& 0xFF
    pc_l = pc &&& 0xFF

    pc_l = if StatusRegister.sign? p do
      X6502.AU.inc_address_8 pc_l, disp
    else
      pc_l
    end
    pc = X6502.AU.to_16bits pc_h, pc_l
    %CPU{state | registers: %{registers | pc: pc}}
  end

  defp real_execute(
    %{mnemonic: :bne},
    nil,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p,
        pc: pc
      }
    }
  ) do

    pc = inc_pc pc, 1
    disp = mm.peek memory, pc
    pc = inc_pc pc, 1

    pc_h = (pc >>> 8) &&& 0xFF
    pc_l = pc &&& 0xFF

    pc_l = if not StatusRegister.zero? p do
      X6502.AU.inc_address_8 pc_l, disp
    else
      pc_l
    end
    pc = X6502.AU.to_16bits pc_h, pc_l
    %CPU{state | registers: %{registers | pc: pc}}
  end

  defp real_execute(
    %{mnemonic: :bpl},
    nil,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p,
        pc: pc
      }
    }
  ) do

    pc = inc_pc pc, 1
    disp = mm.peek memory, pc
    pc = inc_pc pc, 1

    pc_h = (pc >>> 8) &&& 0xFF
    pc_l = pc &&& 0xFF

    pc_l = if not StatusRegister.sign? p do
      X6502.AU.inc_address_8 pc_l, disp
    else
      pc_l
    end
    pc = X6502.AU.to_16bits pc_h, pc_l
    %CPU{state | registers: %{registers | pc: pc}}
  end

  defp real_execute(
    %{mnemonic: :bvc},
    nil,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p,
        pc: pc
      }
    }
  ) do

    pc = inc_pc pc, 1
    disp = mm.peek memory, pc
    pc = inc_pc pc, 1

    pc_h = (pc >>> 8) &&& 0xFF
    pc_l = pc &&& 0xFF

    pc_l = if not StatusRegister.overflow? p do
      X6502.AU.inc_address_8 pc_l, disp
    else
      pc_l
    end
    pc = X6502.AU.to_16bits pc_h, pc_l
    %CPU{state | registers: %{registers | pc: pc}}
  end

  defp real_execute(
    %{mnemonic: :bvs},
    nil,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p,
        pc: pc
      }
    }
  ) do

    pc = inc_pc pc, 1
    disp = mm.peek memory, pc
    pc = inc_pc pc, 1

    pc_h = (pc >>> 8) &&& 0xFF
    pc_l = pc &&& 0xFF

    pc_l = if StatusRegister.overflow? p do
      X6502.AU.inc_address_8 pc_l, disp
    else
      pc_l
    end
    pc = X6502.AU.to_16bits pc_h, pc_l
    %CPU{state | registers: %{registers | pc: pc}}
  end

  defp real_execute(
    %{mnemonic: :jsr},
    nil,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        sp: sp,
        pc: pc
      }
    }
  ) do
    ret_pc = inc_pc pc, 1
    new_pc_l = mm.peek memory, ret_pc

    ret_pc = inc_pc ret_pc, 1
    new_pc_h = mm.peek memory, ret_pc

    ret_pc_h = (ret_pc >>> 8) &&& 0xFF
    ret_pc_l = ret_pc &&& 0xFF

    new_sp_1 = push mm, memory, ret_pc_h, sp
    new_sp_2 = push mm, memory, ret_pc_l, new_sp_1

    new_pc = X6502.AU.to_16bits(new_pc_h, new_pc_l)
    %CPU{state | registers: %{registers | pc: new_pc, sp: new_sp_2}}
  end

  defp real_execute(
    %{mnemonic: :rts},
    nil,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        sp: sp
      }
    }
  ) do
    {new_pc_l, new_sp_1} = pop mm, memory, sp
    {new_pc_h, new_sp_2} = pop mm, memory, new_sp_1
    new_pc = X6502.AU.to_16bits(new_pc_h, new_pc_l)
    new_pc = inc_pc new_pc, 1
    %CPU{state | registers: %{registers | pc: new_pc, sp: new_sp_2}}
  end

  defp real_execute(
    %{mnemonic: :tax},
    nil,
    state = %CPU{
      registers: registers = %{
        a: a,
        p: p
      }
    }
  ) do
    p = set_sign p, a
    p = set_zero p, a
    %CPU{state | registers: %{registers | x: a, p: p}}
  end

  defp real_execute(
    %{mnemonic: :txa},
    nil,
    state = %CPU{
      registers: registers = %{
        x: x,
        p: p
      }
    }
  ) do
    p = set_sign p, x
    p = set_zero p, x
    %CPU{state | registers: %{registers | a: x, p: p}}
  end

  defp real_execute(
    %{mnemonic: :tay},
    nil,
    state = %CPU{
      registers: registers = %{
        a: a,
        p: p
      }
    }
  ) do
    p = set_sign p, a
    p = set_zero p, a
    %CPU{state | registers: %{registers | y: a, p: p}}
  end

  defp real_execute(
    %{mnemonic: :tya},
    nil,
    state = %CPU{
      registers: registers = %{
        y: y,
        p: p
      }
    }
  ) do
    p = set_sign p, y
    p = set_zero p, y
    %CPU{state | registers: %{registers | a: y, p: p}}
  end

  defp real_execute(
    %{mnemonic: :tsx},
    nil,
    state = %CPU{
      registers: registers = %{
        sp: sp,
        p: p
      }
    }
  ) do
    p = set_sign p, sp
    p = set_zero p, sp
    %CPU{state | registers: %{registers | x: sp, p: p}}
  end

  defp real_execute(
    %{mnemonic: :txs},
    nil,
    state = %CPU{
      registers: registers = %{
        x: x
      }
    }
  ) do
    %CPU{state | registers: %{registers | sp: x}}
  end

  defp real_execute(
    %{mnemonic: :dex},
    nil,
    state = %CPU{
      registers: registers = %{
        p: p,
        x: x
      }
    }
  ) do
    x = (x - 1) &&& 0xFF
    p = set_sign p, x
    p = set_zero p, x
    %CPU{state | registers: %{registers | p: p, x: x}}
  end

  defp real_execute(
    %{mnemonic: :dey},
    nil,
    state = %CPU{
      registers: registers = %{
        p: p,
        y: y
      }
    }
  ) do
    y = (y - 1) &&& 0xFF
    p = set_sign p, y
    p = set_zero p, y
    %CPU{state | registers: %{registers | p: p, y: y}}
  end

  defp real_execute(
    %{mnemonic: :inx},
    nil,
    state = %CPU{
      registers: registers = %{
        p: p,
        x: x
      }
    }
  ) do
    x = (x + 1) &&& 0xFF
    p = set_sign p, x
    p = set_zero p, x
    %CPU{state | registers: %{registers | p: p, x: x}}
  end

  defp real_execute(
    %{mnemonic: :iny},
    nil,
    state = %CPU{
      registers: registers = %{
        p: p,
        y: y
      }
    }
  ) do
    y = (y + 1) &&& 0xFF
    p = set_sign p, y
    p = set_zero p, y
    %CPU{state | registers: %{registers | p: p, y: y}}
  end

  defp real_execute(
    %{mnemonic: :rol},
    nil,
    state = %CPU{
      registers: registers = %{
        a: a,
        p: p
      }
    }
  ) do
    c = ALU.bit_set? a, 7
    a = (a <<< 1) &&& 0xFF
    a = a ||| c
    p = StatusRegister.set_carry p, c
    p = set_zero p, a
    p = set_sign p, a
    %CPU{state | registers: %{registers | a: a, p: p}}
  end

  defp real_execute(
    %{mnemonic: :rol},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p
      }
    }
  ) do
    data = mm.peek memory, operand_location
    c = ALU.bit_set? data, 7
    data = (data <<< 1) &&& 0xFF
    data = data ||| c
    p = StatusRegister.set_carry p, c
    p = set_zero p, data
    p = set_sign p, data
    mm.poke memory, operand_location, data
    %CPU{state | registers: %{registers | p: p}}
  end

  defp real_execute(
    %{mnemonic: :ror},
    nil,
    state = %CPU{
      registers: registers = %{
        a: a,
        p: p
      }
    }
  ) do
    c = ALU.bit_set? a, 0
    a = (a >>> 1) &&& 0xFF
    a = a ||| (c <<< 7)
    p = StatusRegister.set_carry p, c
    p = set_zero p, a
    p = set_sign p, a
    %CPU{state | registers: %{registers | a: a, p: p}}
  end

  defp real_execute(
    %{mnemonic: :ror},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p
      }
    }
  ) do
    data = mm.peek memory, operand_location
    c = ALU.bit_set? data, 0
    data = (data >>> 1) &&& 0xFF
    data = data ||| (c <<< 7)
    p = StatusRegister.set_carry p, c
    p = set_zero p, data
    p = set_sign p, data
    mm.poke memory, operand_location, data
    %CPU{state | registers: %{registers | p: p}}
  end

  defp real_execute(
    %{mnemonic: :asl},
    nil,
    state = %CPU{
      registers: registers = %{
        a: a,
        p: p
      }
    }
  ) do
    c = ALU.bit_set? a, 7
    a = (a <<< 1) &&& 0xFF
    p = StatusRegister.set_carry p, c
    p = set_zero p, a
    p = set_sign p, a
    %CPU{state | registers: %{registers | a: a, p: p}}
  end

  defp real_execute(
    %{mnemonic: :asl},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p
      }
    }
  ) do
    data = mm.peek memory, operand_location
    c = ALU.bit_set? data, 7
    data = (data <<< 1) &&& 0xFF
    p = StatusRegister.set_carry p, c
    p = set_zero p, data
    p = set_sign p, data
    mm.poke memory, operand_location, data
    %CPU{state | registers: %{registers | p: p}}
  end

  defp real_execute(
    %{mnemonic: :lsr},
    nil,
    state = %CPU{
      registers: registers = %{
        a: a,
        p: p
      }
    }
  ) do
    c = ALU.bit_set? a, 0
    a = (a >>> 1) &&& 0xFF
    p = StatusRegister.set_carry p, c
    p = set_zero p, a
    p = set_sign p, 0
    %CPU{state | registers: %{registers | a: a, p: p}}
  end

  defp real_execute(
    %{mnemonic: :lsr},
    operand_location,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p
      }
    }
  ) do
    data = mm.peek memory, operand_location
    c = ALU.bit_set? data, 0
    data = (data >>> 1) &&& 0xFF
    p = StatusRegister.set_carry p, c
    p = set_zero p, data
    p = set_sign p, 0
    mm.poke memory, operand_location, data
    %CPU{state | registers: %{registers | p: p}}
  end

  defp real_execute(
    %{mnemonic: :pha},
    nil,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        a: a,
        sp: sp
      }
    }
  ) do
    new_sp_0 = push mm, memory, a, sp
    %CPU{state | registers: %{registers | sp: new_sp_0}}
  end

  defp real_execute(
    %{mnemonic: :pla},
    nil,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        sp: sp,
        p: p
      }
    }
  ) do
    {new_a, new_sp_0} = pop mm, memory, sp
    p = set_zero p, new_a
    p = set_sign p, new_a
    %CPU{state | registers: %{registers | p: p, a: new_a, sp: new_sp_0}}
  end

  defp real_execute(
    %{mnemonic: :php},
    nil,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p,
        sp: sp
      }
    }
  ) do
    new_sp_0 = push mm, memory, p, sp
    %CPU{state | registers: %{registers | sp: new_sp_0}}
  end

  defp real_execute(
    %{mnemonic: :plp},
    nil,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        sp: sp
      }
    }
  ) do
    {new_p, new_sp_0} = pop mm, memory, sp
    %CPU{state | registers: %{registers | p: new_p, sp: new_sp_0}}
  end

  defp real_execute(
    %{mnemonic: :cli},
    nil,
    state = %CPU{
      registers: registers = %{
        p: p
      }
    }
  ) do
    p = StatusRegister.clear_interrupt_disable p
    %CPU{state | registers: %{registers | p: p}}
  end

  defp real_execute(
    %{mnemonic: :sei},
    nil,
    state = %CPU{
      registers: registers = %{
        p: p
      }
    }
  ) do
    p = StatusRegister.set_interrupt_disable p
    %CPU{state | registers: %{registers | p: p}}
  end

  defp real_execute(
    %{mnemonic: :rti},
    nil,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        sp: sp
      }
    }
  ) do
    {new_p, new_sp_0} = pop mm, memory, sp
    {new_pc_l, new_sp_1} = pop mm, memory, new_sp_0
    {new_pc_h, new_sp_2} = pop mm, memory, new_sp_1
    new_pc = (X6502.AU.to_16bits(new_pc_h, new_pc_l)) &&& 0xFFFF
    %CPU{state | registers: %{registers | p: new_p, pc: new_pc, sp: new_sp_2}}
  end

  defp real_execute(
    %{mnemonic: :brk},
    nil,
    state = %CPU{
      mm: mm,
      memory: memory,
      registers: registers = %{
        p: p,
        sp: sp,
        pc: current_pc
      }
    }
  ) do
    new_pc_h = mm.peek memory, 0xFFFF
    new_pc_l = mm.peek memory, 0xFFFE
    new_pc = X6502.AU.to_16bits new_pc_h, new_pc_l

    current_pc = inc_pc current_pc, 2
    current_pc_h = (current_pc >>> 8) &&& 0xFF
    current_pc_l = current_pc &&& 0xFF
    new_sp_1 = push mm, memory, current_pc_h, sp
    new_sp_2 = push mm, memory, current_pc_l, new_sp_1
    new_sp = push mm, memory, p, new_sp_2

    p = StatusRegister.set_break p
    p = StatusRegister.set_interrupt_disable p
    %CPU{state | registers: %{registers | p: p, pc: new_pc, sp: new_sp}}
  end

  defp real_execute(
    %{mnemonic: :clc},
    nil,
    state = %CPU{
      registers: registers = %{
        p: p
      }
    }
  ) do
    p = StatusRegister.clear_carry p
    %CPU{state | registers: %{registers | p: p}}
  end

  defp real_execute(
    %{mnemonic: :sec},
    nil,
    state = %CPU{
      registers: registers = %{
        p: p
      }
    }
  ) do
    p = StatusRegister.set_carry p
    %CPU{state | registers: %{registers | p: p}}
  end

  defp real_execute(
    %{mnemonic: :cld},
    nil,
    state = %CPU{
      registers: registers = %{
        p: p
      }
    }
  ) do
    p = StatusRegister.clear_decimal_mode p
    %CPU{state | registers: %{registers | p: p}}
  end

  defp real_execute(
    %{mnemonic: :sed},
    nil,
    state = %CPU{
      registers: registers = %{
        p: p
      }
    }
  ) do
    p = StatusRegister.set_decimal_mode p
    %CPU{state | registers: %{registers | p: p}}
  end

  defp real_execute(
    %{mnemonic: :clv},
    nil,
    state = %CPU{
      registers: registers = %{
        p: p
      }
    }
  ) do
    p = StatusRegister.clear_overflow p
    %CPU{state | registers: %{registers | p: p}}
  end

  defp real_execute(%{mnemonic: :nop}, _operand_location, state) do
    state
  end
  ##############################################################################
  # Some helpers.
  ##############################################################################
  defp push(mm, memory, byte, sp) do
    address = X6502.AU.to_16bits 0x01, sp
    mm.poke memory, address, byte
    X6502.AU.inc_address_8 sp, -1
  end

  defp pop(mm, memory, sp) do
    new_sp = X6502.AU.inc_address_8 sp, 1
    address = X6502.AU.to_16bits 0x01, new_sp
    byte = mm.peek memory, address
    {byte, new_sp}
  end

  defp set_sign(p, byte) do
    <<sign::size(1), _::size(7)>> = <<byte::size(8)>>
    case sign do
      1 -> StatusRegister.set_sign p
      0 -> StatusRegister.clear_sign p
    end
  end

  defp set_overflow(p, byte) do
    <<_::size(1), ov::size(1), _::size(6)>> = <<byte::size(8)>>
    case ov do
      1 -> StatusRegister.set_overflow p
      0 -> StatusRegister.clear_overflow p
    end
  end

  defp set_zero(p, 0) do
    StatusRegister.set_zero p
  end

  defp set_zero(p, _) do
    StatusRegister.clear_zero p
  end

  defp inc_pc(pc, n) do
    (pc + n) &&& 0xFFFF
  end
end
