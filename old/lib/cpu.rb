TRACE_MODE = true

class CPU
  ILLEGAL_OPCODE = "#"
  
  def initialize(zmachine)
    @zmachine = zmachine
  end
  
  def exec_next(pc)
    print "" << pc << ": " if TRACE_MODE
    return pc # should actually increment it
  end
  
  def exec(opcode, *ops)
    print "" << opcode << " " << ops.join(" ") << "\n" if TRACE_MODE
    return method(opcode).call(*ops)
  end

  private
  
  def illegal
    error "Illegal opcode"
  end
  
  def add(op1, op2, result)
    store(result, op1 + op2)
  end
  
  def sub(op1, op2, result)
    store(result, op1 - op2)
  end
  
  def mul(op1, op2, result)
    store(result, op1 * op2)
  end
  
  def div(op1, op2, result)
    error "Division by zero" if op2.signed == 0
    store(result, op1 / op2)
  end
  
  def mod(op1, op2, result)
    error "Division by zero" if op2.signed == 0
    store(result, op1 % op2)
  end
  
  # The next three opcodes have an added underscore in their names
  # to avoid clashing with Ruby's keywords.
  
  def and_(op1, op2, result)
    store(result, op1 & op2)
  end

  def not_(op, result)
    store(result, ~op)
  end

  def or_(op1, op2, result)
    store(result, op1 | op2)
  end
  
  def new_line
    @zmachine.out << "\n"
  end
  
  def print(literal_string)
    @zmachine.out << literal_string.to_s
  end
  
  def print_addr(byte_address_of_string)
    @zmachine.out << Text.new(@zmachine.mem, byte_address_of_string).to_s
  end
  
  def print_char(output_character_code)
    @zmachine.out << @zmachine.decode(output_character_code)
  end
  
  def print_num(value)
    @zmachine.out << value.signed.to_s
  end
  
  def nop
  end
  
  def input_stream(number)
  end
  
  def output_stream(number)
  end
  
  def sound_effect(number, effect, volume, routine)
  end
  
  def inc(result)
    store(result, @zmachine.read_var(result).inc)
  end
  
  def dec(result)
    store(result, @zmachine.read_var(result).dec)
  end
  
  def push(word)
    @zmachine.stack.push(word)
  end
  
  def pop
    @zmachine.stack.pop
  end
  
  def pull(result)
    store(result, @zmachine.stack.pop)
  end
  
  def quit
    @zmachine.stop
  end
  
  def restart
    @zmachine.restart
  end
  
  def random(n)
    # TODO: Z-machine return, not Ruby return!
    # TODO: follow the guidelines for random seeds
    return rand(n) + 1 if n > 0
    srand(n) # seed if n < 0, randomized seed otherwise
    return 0
  end
  
  def load(var, result)
    @zmachine.write_var(result, @zmachine.read_var(var))
  end
  
  def store(var, value)
    @zmachine.write_var(var, value)
  end
end
