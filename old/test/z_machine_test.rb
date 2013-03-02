require 'test/unit'
require 'games'
require 'z_machine'

class ZMachineTest < Test::Unit::TestCase

  def setup
    @zm = ZMachine.new([0] * 100)
  end
    
  def test_reads_the_zmachine_version_from_the_file
    assert_equal(3, ZMachine.new(Games.instance["zork"]).version)
  end
  
  def test_restart_restores_the_original_memory_minus_the_two_lesser_bits_of_flags_2
    @zm.mem.each_index {|i| @zm.mem[i] = 255 }
    @zm.restart
    @zm.mem.each_index do |i|
      if i == Memory::FLAGS_2
        assert_equal(0b00000011, @zm.mem[i])
      else
        assert_equal(0, @zm.mem[i])
      end
    end
  end
  
  def test_variable_0_is_the_stack
    w = Word.int(10)
    
    @zm.write_var(0, w)
    assert_equal(w, @zm.stack.pop)
    
    assert !@zm.stack.can_pop?
    @zm.stack.push(w)
    assert_equal(w, @zm.read_var(0))
    assert !@zm.stack.can_pop?
  end
  
  def test_writing_to_variable_nil_is_legal_and_does_nothing
    @zm.write_var(nil, Word.int(1))
  end
  
  def test_cannot_exceed_the_maximum_memory_size
    begin
      ZMachine.new([0] * (65 * 1024))
      fail
    rescue ZError; end
  end
end
