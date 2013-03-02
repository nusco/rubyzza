require 'memory'
require 'stack'
require 'cpu'
require 'zscii'

class ZMachine

  STATE_NEW = 0
  STATE_RUNNING = 1
  STATE_WAITING_FOR_INPUT = 2
  STATE_STOPPED = 3

  attr_reader :mem, :out, :stack, :state
  
  def initialize(bytes)
    error "Memory size out of bounds" if bytes.size > MAX_MEMORY_SIZE
    @mem = Memory.new(bytes)
    @START_MEM = Memory.new(bytes)
    @out = ""
    @cpu = CPU.new(@mem)
    @stack = Stack.new(@mem)
    @ZSCII = ZSCII.new
    @state = STATE_NEW
  end
  
  def send(input)
    error "The Z Machine was not waiting for input" if @state != STATE_WAITING_FOR_INPUT
    @state = STATE_RUNNING
    return "xyz\n"
  end
  
  def decode(zscii_char)
    return @ZSCII[zscii_char]
  end
  
  def start
    error "The Z Machine has already been started" if @state != STATE_NEW
    @state = STATE_RUNNING
    first_instruction = @mem[0x06]
    @pc = first_instruction
    exec_loop
    return "started\n"
  end
  
  def stop
    @state = STATE_STOPPED
  end
  
  def read
    @state = STATE_WAITING_FOR_INPUT
  end
  
  def version
    @mem[0]
  end

  def active?
    @state != STATE_STOPPED
  end

  # TODO: manage stack, local variables, etc.
  def write_var(var, value)
    if(var == 0)
      stack.push(value)
      return
    end
    return @mem.write_global_var(var, value)
  end
  
  def read_var(var)
    return stack.pop if(var == 0)
    return @mem.read_global_var(var)
  end
  
  def[](byte_address)
    @mem[byte_address]
  end
  
  def[]=(byte_address, byte)
    @mem[byte_address] = byte
  end
  
  def restart
    flags2 = @mem[Memory::FLAGS_2]
    @mem = @START_MEM
    @mem[Memory::FLAGS_2] = flags2 & 0b11
    # TODO clean other memories
    # TODO reset PC
  end
  
  private
  
  MAX_MEMORY_SIZE = 64 * 1024 - 2

  def first_instruction
    @mem[0x06]
  end
  
  def exec_loop
    while @state != STATE_RUNNING
      @pc = @cpu.exec_next(@pc)
    end
  end
  
end
