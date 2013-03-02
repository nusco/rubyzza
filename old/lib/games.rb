require 'singleton'
require 'z_machine'

class Games < Hash

  GAMES_DIR = "games/"
  
  include Singleton

  def initialize
    Dir.glob(GAMES_DIR + "*.z3") do |file|
      game = Game.new(file)
      self[game.short_name] = game
      ZMachine.new(game)
    end
  end
  
end

class Game < Array
  
  attr_reader :short_name, :name

  def initialize(game_file)
    @short_name = game_file.split(".")[0].split("/")[1]
    self.replace(open(game_file))
    @name = load_name
  end
  
  def to_s
    @short_name + "\t" + @name
  end
  
  def []=(idx, value)
    raise "Games are read-only"
  end
  
  private

  def load_name
    cfg = Games::GAMES_DIR + @short_name + ".cfg"
    return "" if !File::exists?(cfg)
    File.open(cfg) {|file| return file.readline.strip }
  end
  
  def open(game_file)
    IO.read(game_file).to_a
  end
  
end  
