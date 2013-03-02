require 'test/unit'
require 'cpu'
require 'text'
require 'z_machine'

class CPUTest < Test::Unit::TestCase

  GLOBAL_VAR = 0x11

  def setup
    @zmachine = ZMachine.new(Memory.new([
                              255, 255,            # nothing interesting
                              3, 0, 1, 0, 2, 0, 3  # routine at 1: 3 variables with values 1, 2, 3
                              ]))
    @cpu = CPU.new(@zmachine)
  end

  def test_add
    @cpu.exec "add", Word.int(-5), Word.int(3), GLOBAL_VAR
    assert_equal(-2, result)
  end

  def test_sub
    @cpu.exec "sub", Word.int(-5), Word.int(-3), GLOBAL_VAR
    assert_equal(-2, result)
  end

  def test_mul
    @cpu.exec "mul", Word.int(-5), Word.int(3), GLOBAL_VAR
    assert_equal(-15, result)
  end
  
  def test_div
    @cpu.exec "div", Word.int(-11), Word.int(2), GLOBAL_VAR
    assert_equal(-5, result)
    @cpu.exec "div", Word.int(-11), Word.int(-2), GLOBAL_VAR
    assert_equal(5, result)
    @cpu.exec "div", Word.int(11), Word.int(-2), GLOBAL_VAR
    assert_equal(-5, result)
  end
  
  def test_mod
    @cpu.exec "mod", Word.int(-13), Word.int(5), GLOBAL_VAR
    assert_equal(-3, result)
    @cpu.exec "mod", Word.int(13), Word.int(-5), GLOBAL_VAR
    assert_equal(3, result)
    @cpu.exec "mod", Word.int(-13), Word.int(-5), GLOBAL_VAR
    assert_equal(-3, result)
  end
    
  def test_division_by_zero_is_illegal
    begin
      @cpu.exec "div", Word.int(-5), Word.int(0), GLOBAL_VAR
      fail
    rescue ZError; end
  end

  def test_module_by_zero_is_illegal
    begin
      @cpu.exec "mod", Word.int(-5), Word.int(0), GLOBAL_VAR
      fail
    rescue ZError; end
  end
  
  def test_and
    w1 = Word.bytes(0b11111111, 0b00000011)
    w2 = Word.bytes(0b00000001, 0b11111111)
    @cpu.exec "and_", w1, w2, GLOBAL_VAR
    assert_equal(259, result)
  end

  def test_or
    w1 = Word.bytes(0b11111111, 0b11111110)
    w2 = Word.bytes(0b00000000, 0b00000001)
    @cpu.exec "or_", w1, w2, GLOBAL_VAR
    assert_equal(0xffff, @zmachine.read_var(GLOBAL_VAR).unsigned)
  end
  
  def test_not
    @cpu.exec "not_", Word.bytes(255, 0b11111110), GLOBAL_VAR
    assert_equal(1, result)
  end
  
  def test_inc
    force_global_var(-1)
    @cpu.exec "inc", GLOBAL_VAR
    assert_equal(0, result)
  end
  
  def test_dec
    force_global_var(0)
    @cpu.exec "dec", GLOBAL_VAR
    assert_equal(-1, result)
  end
  
  def test_push
    @cpu.exec "push", Word.int(3)
    assert_equal(3, @zmachine.stack.pop.unsigned)
  end
  
  def test_pop
    @zmachine.stack.push(Word.int(3))
    @cpu.exec "pop"
    assert !@zmachine.stack.can_pop?
  end
  
  def test_pull
    @zmachine.stack.push(Word.int(3))
    force_global_var(0)
    @cpu.exec "pull", GLOBAL_VAR
    assert !@zmachine.stack.can_pop?
    assert_equal(3, result)
  end
  
  def test_load
    @zmachine.write_var(90, Word.int(7))
    @cpu.exec "load", 90, GLOBAL_VAR
    assert_equal(7, result)
  end
  
  def test_store
    @cpu.exec "store", GLOBAL_VAR, Word.int(10)
    assert_equal(10, result)
  end
  
  def test_new_line
    @cpu.exec "new_line"
    assert_equal("\n", @zmachine.out)
  end
  
  def test_print
    txt = Text.new(Memory.new([0b1_00110_00, 0b111_01000]), 0)
    @cpu.exec "print", txt
    assert_equal("abc", @zmachine.out)
  end
  
  def test_print_addr
    @zmachine[9] = 0b1_00110_00
    @zmachine[10] = 0b111_01000
    @cpu.exec "print_addr", 9
    assert_equal("abc", @zmachine.out)
  end
  
  def test_print_char
    @cpu.exec "print_char", 13
    assert_equal('\n', @zmachine.out)
  end
  
  def test_print_num
    @cpu.exec "print_num", Word.int(-7)
    assert_equal("-7", @zmachine.out)
  end

  def test_quit
    @cpu.exec "quit"
    assert !@zmachine.active?
  end

  def test_call
    # call routine at packed address 1 with args 101, 102, 103
    # and store result on stack
    @cpu.exec "call", 1, 101, 102, 103, 0
  end
    
  def test_illegal
    begin
      @cpu.exec CPU::ILLEGAL_OPCODE
      fail
    rescue ZError; end
  end
  
  def test_unsupported_opcodes
    # These opcodes are not supported in Rubyzza. They do nothing,
    # but they shouldn't cause an error
    @cpu.exec "input_stream", 0
    @cpu.exec "output_stream", 0
    @cpu.exec "sound_effect", 0, 0, 0, 0
  end
  
  def result
    return @zmachine.read_var(GLOBAL_VAR).signed
  end
  
  def force_global_var(int)
    @zmachine.write_var(GLOBAL_VAR, Word.int(int))
  end
end
