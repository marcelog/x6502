defmodule X6502.StatusRegister do
  alias X6502.ALU, as: ALU

  @flags %{
    carry: 0,
    zero: 1,
    interrupt_disable: 2,
    decimal_mode: 3,
    break: 4,
    reserved: 5,
    overflow: 6,
    sign: 7
  }

  @doc """
  Sets the sign flag.

  ## Examples

      iex> X6502.StatusRegister.set_sign 0
      128

      iex> X6502.StatusRegister.set_sign 0, 1
      128

      iex> X6502.StatusRegister.set_sign 128, 0
      0
  """
  def set_sign(status) do
    set status, :sign
  end
  def set_sign(status, value) do
    set status, :sign, value
  end

  @doc """
  Tests the sign flag.

  ## Examples

      iex> X6502.StatusRegister.sign? 128
      true
      iex> X6502.StatusRegister.sign? 1
      false

  """
  def sign?(status) do
    set? status, :sign
  end

  @doc """
  Clears the sign flag.

  ## Examples

      iex> X6502.StatusRegister.clear_sign 128
      0
  """
  def clear_sign(status) do
    clear status, :sign
  end

  @doc """
  Sets the decimal_mode flag.

  ## Examples

      iex> X6502.StatusRegister.set_decimal_mode 0
      8

      iex> X6502.StatusRegister.set_decimal_mode 0, 1
      8

      iex> X6502.StatusRegister.set_decimal_mode 8, 0
      0
  """
  def set_decimal_mode(status) do
    set status, :decimal_mode
  end
  def set_decimal_mode(status, value) do
    set status, :decimal_mode, value
  end

  @doc """
  Tests the decimal_mode flag.

  ## Examples

      iex> X6502.StatusRegister.decimal_mode? 8
      true
      iex> X6502.StatusRegister.decimal_mode? 0
      false

  """
  def decimal_mode?(status) do
    set? status, :decimal_mode
  end

  @doc """
  Clears the decimal mode flag.

  ## Examples

      iex> X6502.StatusRegister.clear_decimal_mode 8
      0
  """
  def clear_decimal_mode(status) do
    clear status, :decimal_mode
  end

  @doc """
  Sets the overflow flag.

  ## Examples

      iex> X6502.StatusRegister.set_overflow 0
      64

      iex> X6502.StatusRegister.set_overflow 0, 1
      64

      iex> X6502.StatusRegister.set_overflow 64, 0
      0
  """
  def set_overflow(status) do
    set status, :overflow
  end
  def set_overflow(status, value) do
    set status, :overflow, value
  end

  @doc """
  Tests the overflow flag.

  ## Examples

      iex> X6502.StatusRegister.overflow? 64
      true
      iex> X6502.StatusRegister.overflow? 1
      false

  """
  def overflow?(status) do
    set? status, :overflow
  end

  @doc """
  Clears the overflow flag.

  ## Examples

      iex> X6502.StatusRegister.clear_overflow 64
      0
  """
  def clear_overflow(status) do
    clear status, :overflow
  end

  @doc """
  Sets the carry flag.

  ## Examples

      iex> X6502.StatusRegister.set_carry 0
      1

      iex> X6502.StatusRegister.set_carry 0, 1
      1

      iex> X6502.StatusRegister.set_carry 1, 0
      0
  """
  def set_carry(status) do
    set status, :carry
  end
  def set_carry(status, value) do
    set status, :carry, value
  end

  @doc """
  Tests the carry flag.

  ## Examples

      iex> X6502.StatusRegister.carry? 64
      false
      iex> X6502.StatusRegister.carry? 1
      true

  """
  def carry?(status) do
    set? status, :carry
  end

  @doc """
  Clears the carry flag.

  ## Examples

      iex> X6502.StatusRegister.clear_carry 1
      0
  """
  def clear_carry(status) do
    clear status, :carry
  end

  @doc """
  Sets the zero flag.

  ## Examples

      iex> X6502.StatusRegister.set_zero 0
      2

      iex> X6502.StatusRegister.set_zero 0, 1
      2

      iex> X6502.StatusRegister.set_zero 2, 0
      0
  """
  def set_zero(status) do
    set status, :zero
  end
  def set_zero(status, value) do
    set status, :zero, value
  end

  @doc """
  Tests the zero flag.

  ## Examples

      iex> X6502.StatusRegister.zero? 64
      false
      iex> X6502.StatusRegister.zero? 2
      true

  """
  def zero?(status) do
    set? status, :zero
  end

  @doc """
  Clears the zero flag.

  ## Examples

      iex> X6502.StatusRegister.clear_zero 2
      0
  """
  def clear_zero(status) do
    clear status, :zero
  end

  @doc """
  Sets the break flag.

  ## Examples

      iex> X6502.StatusRegister.set_break 0
      16

      iex> X6502.StatusRegister.set_break 0, 1
      16

      iex> X6502.StatusRegister.set_break 16, 0
      0
  """
  def set_break(status) do
    set status, :break
  end
  def set_break(status, value) do
    set status, :break, value
  end

  @doc """
  Tests the break flag.

  ## Examples

      iex> X6502.StatusRegister.break? 16
      true
      iex> X6502.StatusRegister.break? 0
      false

  """
  def break?(status) do
    set? status, :break
  end

  @doc """
  Clears the break mode flag.

  ## Examples

      iex> X6502.StatusRegister.clear_break 16
      0
  """
  def clear_break(status) do
    clear status, :break
  end

  @doc """
  Sets the interrupt_disable flag.

  ## Examples

      iex> X6502.StatusRegister.set_interrupt_disable 0
      4

      iex> X6502.StatusRegister.set_interrupt_disable 0, 1
      4

      iex> X6502.StatusRegister.set_interrupt_disable 4, 0
      0
  """
  def set_interrupt_disable(status) do
    set status, :interrupt_disable
  end
  def set_interrupt_disable(status, value) do
    set status, :interrupt_disable, value
  end

  @doc """
  Tests the interrupt_disable flag.

  ## Examples

      iex> X6502.StatusRegister.interrupt_disable? 4
      true
      iex> X6502.StatusRegister.interrupt_disable? 0
      false

  """
  def interrupt_disable?(status) do
    set? status, :interrupt_disable
  end

  @doc """
  Clears the interrupt_disable mode flag.

  ## Examples

      iex> X6502.StatusRegister.clear_interrupt_disable 4
      0
  """
  def clear_interrupt_disable(status) do
    clear status, :interrupt_disable
  end

  defp set?(status, flag) do
    ALU.bit_set?(status, @flags[flag])
  end

  defp set(status, flag) do
    ALU.bit_set status, @flags[flag]
  end

  defp set(status, flag, 0) do
    clear status, flag
  end
  defp set(status, flag, 1) do
    set status, flag
  end

  defp clear(status, flag) do
    ALU.bit_clear status, @flags[flag]
  end
end