require 'z_error'

# The Stack also manages routine frames, including calls, returns and local variables.
# It also tracks the program counter across routines.
class Stack
  def initialize(zmachine)
    @zmachine = zmachine
    @frames = [InitialFrame.new]
  end
  
  def push(word)
    current_frame.push(word)
  end
  
  def can_pop?
    return !current_frame.empty?
  end
  
  def pop
    error "Illegal stack access" if !can_pop?
    return current_frame.pop
  end
  
  def read_local_var(id)
    return current_frame.local_vars[id]
  end
  
  def write_local_var(id, word)
    current_frame.local_vars[id] = word
  end

  # Calls the routine at packed_addr. Also needs the address of the next instruction
  # to execute after returning (return_addr) and the variable where to store the
  # result after returning (result_var). Can get additional arguments for the routine.  
  # Returns the new value of the program counter (the address of the first instruction
  # to execute inside the routine).
  def call(packed_addr, return_addr, result_var, *args)
    if packed_addr == 0
      @zmachine.write_var(Word.int(0), result_var)
      return    
    end
    error "Too many arguments in routine call" if args.size > 3
    @frames.push(Frame.new(@zmachine.mem, @zmachine.mem.packed(packed_addr), return_addr, result_var, args))
    return current_frame.first_instruction
  end

  # Returns from the current routine with the given value. Removes the routine frame
  # from the stack, thus clearing the local portion of the stack including the local
  # variables of the routine, and stores the result in the variable which was specified
  # when calling the routine.
  # Returns the new value of the program counter (the address of the first instruction
  # to execute after returning from the routine).
  def ret(value)
    error "Attempting to return from main context" if @frames.size == 1
    removed_frame = @frames.pop
    @zmachine.write_var(@frames.result_var, value)
    return removed_frame.return_addr
  end

  private
  
  def current_frame
    return @frames.last
  end

  # The portion of the stack belonging to a single routine.
  # Maintains the local part of the stack and the local variables
  # (after initializing them from memory).
  # Also remembers the address to return to.
  class Frame < Array
    attr_reader :local_vars, :return_addr, :result_var, :first_instruction
    
    def initialize(memory, address, return_addr, result_var, args)
      @return_addr = return_addr
      @result_var = result_var
      num_of_vars = memory[address]
      @local_vars = init_local_vars(memory, num_of_vars, address + 1, args)
      @first_instruction = address + 1 + (num_of_vars * 2)
    end
    
    private
    
    def init_local_vars(memory, num_of_vars, first_var_addr, args)
      result = [nil] # no variable 0
      0.upto(num_of_vars - 1) do |i|
        address_of_value = first_var_addr + (i * 2)
        word = memory.read_word(address_of_value)
        result << word
      end
      args.each_index {|i| result[i + 1] = args[i] }
      return result
    end
  end
  
  class InitialFrame < Frame
    def initialize()
      super([0], 0, 0, nil, [])
    end
  end
end
