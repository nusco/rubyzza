module Rubyzza
  class ZSCII < Hash
    def initialize
      super ''
      self[13] = '\n'
      (32..126).each {|i| self[i] = i.chr }
      UNICODES.each_index {|i| self[i + 155] = UNICODES[i].chr }
    end
  
    def encode(char)
      index(char)
    end
  
    UNICODES = [
      228, 246, 252, 196, 214, 220, 223, 171,
      187, 235, 226, 234, 238, 244, 251, 194,
      202, 206, 212, 219, 239, 255, 203, 207, 
      225, 233, 237, 243, 250, 253, 193, 201,
      205, 211, 218, 221, 224, 232, 236, 242,
      249, 192, 200, 204, 210, 217, 229, 197, 
      248, 216, 227, 241, 245, 195, 209, 213,
      230, 198, 231, 199, 254, 222, 100, 208,
      163, 156, 140, 161, 191
    ]
  end
end