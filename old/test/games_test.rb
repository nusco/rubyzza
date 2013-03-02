require 'test/unit'
require 'games'

class GamesTest < Test::Unit::TestCase
  
  def test_loads_and_stores_games
    assert Games.instance["zork"] != nil
  end
  
  def test_each_game_has_a_short_name
    assert_equal("zork", Games.instance["zork"].short_name)
  end
  
  def test_games_are_read_only
    begin
      Games.instance["zork"][1] = 3
      fail
    rescue; end
  end
  
  def test_each_game_can_have_a_name
    assert_equal("Zork", Games.instance["zork"].name)
    assert_equal("", Games.instance["unlisted"].name)
  end
  
end
