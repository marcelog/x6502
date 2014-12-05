defmodule X6502.ALU do
  use Bitwise

  @doc """
  Tests the byte for the given bit number.

  ## Examples

      iex> X6502.ALU.bit_set? 0x80, 7
      1

      iex> X6502.ALU.bit_set? 0x80, 0
      0

      iex> X6502.ALU.bit_set? 0x81, 0
      1
  """
  @spec bit_set?(byte(), non_neg_integer()):: 0|1
  def bit_set?(byte, bit) do
    mask = bit_value_in_bytes(bit)
    (byte &&& mask) >>> bit
  end

  @doc """
  Sets the given bit in the given byte.

  ## Examples

      iex> X6502.ALU.bit_set 0x80, 0
      0x81

      iex> X6502.ALU.bit_set 0x00, 0
      0x01
  """
  @spec bit_set(byte(), non_neg_integer()):: byte()
  def bit_set(byte, bit) do
    result = byte ||| bit_value_in_bytes(bit)
    result &&& 0xFF
  end

  @doc """
  Clears the given bit in the given byte.

  ## Examples

      iex> X6502.ALU.bit_clear 0x81, 0
      0x80

      iex> X6502.ALU.bit_clear 0x00, 0
      0x00
  """
  @spec bit_clear(byte(), non_neg_integer()):: byte()
  def bit_clear(byte, bit) do
    (byte &&& (~~~bit_value_in_bytes(bit))) &&& 0xFF
  end

  @doc """
  Adds two bytes with carry (optional).
  Returns a tuple like {carry, overflow, result}

  ## Examples

      iex> X6502.ALU.adc 0, 1
      {0, 0, 0x01}

      iex> X6502.ALU.adc 2, 254
      {1, 0, 0x00}

      iex> X6502.ALU.adc 2, 126
      {0, 1, 0x80}

  """
  @spec adc(byte(), byte(), 1|0):: {1|0, 1|0, byte()}
  def adc(a, b, c \\ 0) do
    r = (a &&& 0xFF) + (b &&& 0xFF) + (c &&& 0x01)
    c = if r > 255 do
      1
    else
      0
    end
    r = r &&& 0xFF
    v = overflow? a, b, r
    {c, v, r}
  end

  @doc """
  Subtracts two bytes with carry (optional). This is an adc with two complement
  of (b + carry complement).
  Returns a tuple like {carry, overflow, result}

  Source http://forums.nesdev.com/viewtopic.php?t=8703
  SBC subtracts the opposite of the carry. So for ADC just adding the carry
  will cancel that off-by-one.

  just wondering why SBC can be implemented as ADC(value ^ 0xFF)? Just
  flipping the bits doesn't give a 2s complement sign flip...it's off by one
  Yeah it's off by one, but then you do an add with CARRY so you can use the
  carry to get that one that you're off by. You just have to set the carry
  flag before hand. If the carry bit was clear then you'd be right.

  ## Examples

      iex> X6502.ALU.sbc 0, 0
      {1, 0, 0x00}

      iex> X6502.ALU.sbc 0, 1
      {0, 0, 0xFF}

      iex> X6502.ALU.sbc -126, 126
      {1, 1, 0x04}

      iex> X6502.ALU.sbc 0, 0, 0
      {0, 0, 0xFF}

  """
  @spec sbc(byte(), byte(), 1|0):: {1|0, 1|0, byte()}
  def sbc(a, b, c \\ 1) do

#    bb = b ^^^ 0xFF
#    adc a, bb, c
#
#   OR
#
#
    cc = (~~~c) &&& 0x01
    {_, _, r} = adc b, cc, c
    adc a, two_complement(r), c
  end

  # Source: http://stackoverflow.com/a/16861251/727142
  # Set if two inputs with the same sign produce a result with a different sign.
  # Otherwise it is clear.
  #
  # Source: http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
  # For instance, 80 + 80 = 160 with unsigned arithmetic, but with signed
  # arithmetic the result is unexpectedly -96. The problem is that 160 will fit
  # into a byte as an unsigned number, but it is too big to store in a byte as
  # a signed number. Since the top bit is set, it is interpreted as a negative
  # number. To indicate this problem, the 6502 sets the overflow flag.
  @spec overflow?(byte(), byte(), byte()):: 1|0
  defp overflow?(a, b, c) do
    <<bytea::size(1), _a::size(7)>> = <<a::size(8)>>
    <<byteb::size(1), _b::size(7)>> = <<b::size(8)>>
    <<bytec::size(1), _c::size(7)>> = <<c::size(8)>>
    (~~~(bytea ^^^ byteb)) &&& (bytea ^^^ bytec)
  end

  @spec two_complement(byte()):: byte()
  defp two_complement(byte) do
    0x100 - (byte &&& 0xFF)
  end

  @spec bit_value_in_bytes(byte()):: byte()
  defp bit_value_in_bytes(bit) do
    (1 <<< bit) &&& 0xFF
  end
end

