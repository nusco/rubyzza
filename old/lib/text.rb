require 'zscii'

class Text

  ZSCII = ZSCII.new  
                                                                                          
  def initialize(memory, address)
    @val = to_string(to_zscii(to_zchars(read(memory, address))))
  end

  def to_s
    @val
  end

  private

  def read(memory, address)
    words = []
    begin
      words.push(Word.new(memory[address], memory[address + 1]))
      address = address + 2
    end until higher_bit_set(words.last)
    return words
  end

  def higher_bit_set(word)
    word[15] == 1
  end
  
  def to_zchars(words)
    result = []
    words.each {|word| result = result + decode_word(word) }
    return result
  end
  
  def to_zscii(zchars)
    @a0 = method("alphabet_0")
    @a1 = method("alphabet_1")
    @a2 = method("alphabet_2")
    alphabet = @a0
    stack = Array.new(zchars).reverse
    result = []
    while !stack.empty?
      zscii, alphabet = next_zscii(stack, alphabet)
      result.push(zscii) if zscii != nil
    end
    return result
  end

  def next_zscii(stack, alphabet)
      zchar = stack.pop
      case zchar
        when 0
          return [32, @a0]
        when 4
          return [nil, @a1]
        when 5
          return [nil, @a2]
        else
          result = alphabet.call(zchar, stack)
          return [result, @a0]
      end
  end

  def alphabet_0(zchar, stack)
    zchar - 6 + 0x61  # ['a'..'z']
  end
  
  def alphabet_1(zchar, stack)
    zchar - 6 + 0x41  # ['A'..'Z']
  end
  
  def alphabet_2(zchar, stack)
    return zchars_to_zscii(stack) if zchar == 6
    "\n0123456789.,!?_#'\"/\\-:()"[zchar - 7]
  end
  
  def zchars_to_zscii(stack)
    if stack.size >= 2
      return stack.pop * 32 + stack.pop  # encoded ZSCII
    else
      # incomplete zscii code
      stack.clear
    end
  end
  
  def to_string(zscii)
    result = ""
    zscii.each {|chr| result = result << ZSCII[chr] }
    return result
  end

  def decode_word(word)
    return [word[10..14], word[5..9], word[0..4]]
  end

end
