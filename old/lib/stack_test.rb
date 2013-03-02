require 'test/unit'
require 'stack'
require 'z_machine'
require 'memory'
require 'word'
require 'z_error'

class StackTest < Test::Unit::TestCase
  def setup
    zmachine = ZMachine.new(Memory.new([
                                        255, 255,             # nothing interesting
                                        3, 0, 1, 0, 2, 0, 3,  # routine at 1: 3 variables with values 1, 2, 3
                                        255, 255, 255,        # nothing interesting
                                        1, 0, 100             # routine 6: 1 variable with value 100
                                        ]))
    @s = Stack.new(zmachine)
  end

  def test_push_and_pops
    @s.push(Word.int(3))
    w = @s.pop
    assert_equal(3, w.signed)
  end

  def test_checks_for_underflow
    begin
      @s.pop
      fail
    rescue ZError; end
  end

  def test_returning_from_the_initial_frame_is_illegal
    begin
      @s.ret
      fail
    rescue ZError; end
  end
  
  def test_mantains_local_variables
    @s.call(1, 0, 0)
    assert_equal(Word.int(1), @s.read_local_var(1))    
    assert_equal(Word.int(2), @s.read_local_var(2))    
    assert_equal(Word.int(3), @s.read_local_var(3))    
    begin
      @s.read_local_var(4)
      fail
    rescue; end
    @s.write_local_var(1, Word.int(100))
    assert_equal(100, @s.read_local_var(1).signed)    
  end
  
  def test_manages_call_frames
    # routine 1
    @s.call(1, 0, nil) # throw away result
    assert_equal(1, @s.read_local_var(1).unsigned)    
    @s.push(Word.int(7))
    # routine 6
    @s.call(6, 0, 0) #put result on stack
    assert_equal(100, @s.read_local_var(1).unsigned)
    @s.push(Word.int(8))
    # return to routine 1
    @s.ret(Word.int(13))
    assert_equal(1, @s.read_local_var(1).unsigned)    
    assert_equal(13, @s.pop.unsigned)    
    assert_equal(7, @s.pop.unsigned)    
  end
  
  def test_calling_routine_zero_does_nothing_and_returns_false
    @s.call(1, 0, nil) # throw away result
    assert_equal(1, @s.read_local_var(1).unsigned)    
    @s.call(0, 0, 0) # put result on stack
    assert_equal(0, @s.pop.unsigned)    
    begin
      @s.ret(nil)  # we're still in the main frame
      fail
    rescue ZError; end
  end
  
  def test_accepts_three_arguments_at_most
    begin
      @s.call(1, 0, nil, Word.int(101), Word.int(102), Word.int(103), Word.int(104))
      fail
    rescue ZError; end
  end
  
  def test_uses_arguments_to_init_variables
    @s.call(1, 0, nil, Word.int(101), Word.int(102))
    assert_equal(101, @s.read_local_var(1).unsigned)    
    assert_equal(102, @s.read_local_var(2).unsigned)    
    assert_equal(3, @s.read_local_var(3).unsigned)    
  end
  
  def test_ignores_extra_arguments
    @s.call(6, 0, nil, Word.int(101), Word.int(102))
    assert_equal(101, @s.read_local_var(1).unsigned)    
    begin
      @s.read_local_var(2)
      fail
    rescue; end
  end
  
  def test_tracks_the_program_counter_through_routine_calls
    pc = 10
    pc = @s.call(1, pc, nil)
    assert_equal(9, pc)

    pc = 11
    pc = @s.call(6, pc, nil)
    assert_equal(15, pc)

    pc = @s.ret(nil)
    assert_equal(11, pc)

    pc = @s.ret(nil)
    assert_equal(10, pc)
  end
end
