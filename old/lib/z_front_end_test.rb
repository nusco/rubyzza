require 'test/unit'
require 'z_front_end'

class ZFrontEndTest < Test::Unit::TestCase
  
  def setup
    @zmachine = ZFrontEnd.new([0] * 100)
  end
  
  def test_ignores_messages_starting_with_a_minus_sign
    assert_equal("", @zmachine.process("-anything"))
  end
  
  def test_lists_available_games
    reply = @zmachine.process("!games")
    assert reply.match("zork")
    assert reply.match("Zork")
  end
  
  def test_provides_version
    assert @zmachine.process("!version").size > 0
  end
  
  def test_provides_help
    assert @zmachine.process("!help").size > 0
  end
  
  def test_provides_if_info
    assert @zmachine.process("!if").size > 0
  end
  
  def test_provides_a_list_of_commands
    assert @zmachine.process("!commands").match("!version")
  end
  
  def test_unknown_commands_fail_explicitly
    begin
      @zmachine.process("!unknown")
      fail
    rescue ZError
    end
  end
end
