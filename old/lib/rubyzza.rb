# A simple script that starts a local Z machine

require 'z_machine'
require 'games'

if ARGV.size == 0
  print "\nUsage: ruby rubyzza.rb [game]\n"
  exit
end

game = Game.new(ARGV[0])
zmachine = ZMachine.new(game)
print zmachine.start
$stdin.each do |line|
  print zmachine.send(line)
end
