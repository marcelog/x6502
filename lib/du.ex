defmodule X6502.DU do
  use Bitwise

  @addressing_modes_extra_bytes %{
    accumulator: 0,
    zero_page_preindex: 1,
    zero_page_direct: 1,
    immediate: 1,
    absolute: 2,
    zero_page_postindex: 1,
    zero_page_indexed_x: 1,
    absolute_indexed_y: 2,
    absolute_indexed_x: 2,
    implied: 0
  }

  @ops %{
    set_1: %{
      0b000 => :ora,
      0b001 => :and,
      0b010 => :eor,
      0b011 => :adc,
      0b100 => :sta,
      0b101 => :lda,
      0b110 => :cmp,
      0b111 => :sbc
    },

    set_2: %{
      0b000 => :asl,
      0b001 => :rol,
      0b010 => :lsr,
      0b011 => :ror,
      0b100 => :stx,
      0b101 => :ldx,
      0b110 => :dec,
      0b111 => :inc
    },

    set_3: %{
      0b001 => :bit,
      0b010 => :jmp,
      0b011 => :jmp_indirect,
      0b100 => :sty,
      0b101 => :ldy,
      0b110 => :cpy,
      0b111 => :cpx
    },

    set_4: %{
      0x10 => :bpl,
      0x30 => :bmi,
      0x50 => :bvc,
      0x70 => :bvs,
      0x90 => :bcc,
      0xB0 => :bcs,
      0xD0 => :bne,
      0xF0 => :beq,
      0x08 => :php,
      0x28 => :plp,
      0x48 => :pha,
      0x68 => :pla,
      0x88 => :dey,
      0xA8 => :tay,
      0xC8 => :iny,
      0xE8 => :inx,
      0x18 => :clc,
      0x38 => :sec,
      0x58 => :cli,
      0x78 => :sei,
      0x98 => :tya,
      0xB8 => :clv,
      0xD8 => :cld,
      0xF8 => :sed,
      0x8A => :txa,
      0x9A => :txs,
      0xAA => :tax,
      0xBA => :tsx,
      0xCA => :dex,
      0xEA => :nop,
      0x00 => :brk,
      0x20 => :jsr,
      0x40 => :rti,
      0x60 => :rts
    }
  }

  @addressing_modes %{
    set_1: %{
      0b000 => :zero_page_preindex,
      0b001 => :zero_page_direct,
      0b010 => :immediate,
      0b011 => :absolute,
      0b100 => :zero_page_postindex,
      0b101 => :zero_page_indexed_x,
      0b110 => :absolute_indexed_y,
      0b111 => :absolute_indexed_x
    },

    set_2: %{
      0b000 => :immediate,
      0b001 => :zero_page_direct,
      0b010 => :accumulator,
      0b011 => :absolute,
      0b101 => :zero_page_indexed_x,
      0b111 => :absolute_indexed_x
    },

    set_3: %{
      0b000 => :immediate,
      0b001 => :zero_page_direct,
      0b011 => :absolute,
      0b101 => :zero_page_indexed_x,
      0b111 => :absolute_indexed_x
    },

    set_4: %{
      nil => :implied
    }
  }

  # Source: http://www.llx.com/~nparker/a2/opcodes.html
  def decode(opcode) do
    {set, op, mode} = real_decode <<opcode::size(8)>>
    ori_mode_name = @addressing_modes[set][mode]
    mnemonic = @ops[set][op]
    mode_name = case {mnemonic, ori_mode_name} do
      {:ldx, :absolute_indexed_x} -> :absolute_indexed_y
      {:stx, :absolute_indexed_x} -> :absolute_indexed_y
      {:ldx, :zero_page_indexed_x} -> :zero_page_indexed_y
      {:stx, :zero_page_indexed_x} -> :zero_page_indexed_y
      {_, _} -> ori_mode_name
    end
    %{
      opcode: opcode,
      mnemonic: mnemonic,
      mode: mode_name,
      bytes: 1 + @addressing_modes_extra_bytes[ori_mode_name]
    }
  end

  defp real_decode(<<op::size(8)>> = opbin) do
    case @ops[:set_4][op] do
      nil -> real_decode2 opbin
      _ -> {:set_4, op, nil}
    end
  end

  defp real_decode2(<<op::size(3), mode::size(3), 0::size(1), 1::size(1)>>) do
    {:set_1, op, mode}
  end

  defp real_decode2(<<op::size(3), mode::size(3), 1::size(1), 0::size(1)>>) do
    {:set_2, op, mode}
  end

  defp real_decode2(<<op::size(3), mode::size(3), 0::size(1), 0::size(1)>>) do
    {:set_3, op, mode}
  end
end
