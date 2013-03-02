require 'word'

module Rubyzza
  class ZMachine
    attr_accessor :mem
    
    def load(game_file)
      @mem = IO.read(game_file).bytes.to_a
      @pc = read(0x06).unsigned
      loop { tick }
    end
    
    def tick
      byte = @mem[@pc]
      if(byte & 0b01000000) == 0b01000000 # "long" opcode
        op1_type = (byte & 0b00100000) > 0 ? :small_const : :var
        op2_type = (byte & 0b00010000) > 0 ? :small_const : :var
        
        opcode = byte & 0b00011111
        p opcode
        if opcode == 0xF # loadw array word-index -> (result) 

        end
      end
      exit
    end
    
    def read(addr)
      @mem[addr..addr + 1].to_w
    end
  end
end

#Rubyzza::ZMachine.new.load './games/zork.z3'
