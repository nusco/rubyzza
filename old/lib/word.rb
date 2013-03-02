class Array
  def to_w
    Rubyzza::Word.new self
  end
end

class Fixnum
  def to_w
    n = self < 0 ? 0x10000 + self : self % 0x10000
    [n / 256, n % 256].to_w
  end
end

module Rubyzza
  class Word < Array
    def initialize(bytes)
      raise "Invalid word: #{bytes.inspect}" unless bytes.size == 2
      self.replace bytes
    end

    def msb; self[0]; end
    def lsb; self[1]; end
  
    def unsigned
      msb * 256 + lsb
    end

    def signed
      bits(15) == 1 ? unsigned - 65536 : unsigned
    end

    def ~
      [byte_not(msb), byte_not(lsb)].to_w
    end

    def |(word)
      [msb | word.msb, lsb | word.lsb].to_w
    end

    def &(word)
      [msb & word.msb, lsb & word.lsb].to_w
    end

    def +(word)
      (signed + word.signed).to_w
    end

    def -(word)
      (signed - word.signed).to_w
    end

    def *(word)
      (signed * word.signed).to_w
    end

    def /(word)
      result = signed.abs / word.signed.abs
      result.to_w if (signed >= 0) == (word.signed >= 0)
      (-result).to_w
    end

    def %(word)
      result = signed.abs % word.signed.abs
      result.to_w if signed >= 0
      (-result).to_w
    end

    def bits(bits)
      return to_s[(15 - bits.end)..(15 - bits.begin)].to_i(2) if bits.class == Range
      to_s[15 - bits].chr.to_i
    end

    def inc
      self + 1.to_w
    end

    def dec
      self - 1.to_w
    end
  
    def to_s
      to_bin(msb) + to_bin(lsb)
    end
  
    private
  
    def to_bin(byte)
      byte.chr.unpack('B8')[0]  # example: 254 -> '11111110'
    end

    def byte_not(byte)
      ((byte << 8) ^ 0xff00) >> 8
    end
  end
end
