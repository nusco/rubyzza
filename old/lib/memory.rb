require 'word'
require 'z_error'

module Rubyzza
  class Memory < Array
    def word(addr)
      addr * 2
    end

    def packed(addr)
      addr * 2
    end
  
    def write_word(addr, value)
      self[addr..addr+1] = value.to_w
    end
  
    def read_word(addr)
      self[addr..addr + 1].to_w
    end  
  
    def write_global_var(id, value)
      check_global_var(id)
      self[var_addr(id), var_addr(id)+1] = value
    end
  
    def read_global_var(id)
      check_global_var(id)
      self[var_addr(id)..var_addr(id)+1].to_w
    end
  
    private

    GLOBAL_VARS_BASE_ADDR = 0x6e3
    FLAGS_2 = 0x10
  
    def var_addr(addr)
      GLOBAL_VARS_BASE_ADDR + (addr - 0x10) * 2
    end
  
    def check_global_var(id)
      error "Illegal global variable #{id}" if id < 0x10 or id > 0xff
    end  
  end
end
