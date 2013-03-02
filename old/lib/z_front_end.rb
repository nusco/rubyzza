require 'z_machine'
require 'z_error'
require 'games'

class ZFrontEnd < ZMachine
  VERSION = "Rubyzza Alpha 1 (5/3/2006)"
  
  COMMAND_ID = "!"
  COMMAND_METHOD_ID = "cmd_"
  
  def process(input)
    return "" if input[0] == '-'
    output = execute(input.sub(COMMAND_ID, COMMAND_METHOD_ID)) if input.match(COMMAND_ID)
    return "" if output == nil
    return output
  end
  
  def cmd_games
    return Array.new(Games.instance.values).collect {|game| game.to_s }.join('\n')
  end
  
  def cmd_help
    return "TODO"
  end
  
  def cmd_if
    return "TODO"
  end
  
  def cmd_version
    return VERSION
  end
  
  def cmd_commands
    result = []
    methods.sort.each do |m|
      result << m.sub(COMMAND_METHOD_ID, COMMAND_ID) if m.match(COMMAND_METHOD_ID)
    end
    return result.join(", ")
  end

  private

  def execute(method_name, *args)
    begin
      m = method(method_name)
    rescue
      error "Unknown command ", method_name if m == nil
    end
    m.call(*args)
  end
end
