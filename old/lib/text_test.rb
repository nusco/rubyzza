require 'test/unit'
require 'text'
require 'memory'

class TextTest < Test::Unit::TestCase
  
  def test_reads_strings_from_memory_using_byte_addresses
    memory = Memory.new([0, 0, 0b0_00110_00, 0b111_01000, 0b1_00110_00, 0b111_01000])  # "abcabc"
    assert_equal("abcabc", Text.new(memory, 2).to_s)
  end
  
  def test_shift_zchars_change_alphabet
    memory = Memory.new([0b0_00110_00, 0b100_00110,  # "a" - zchar4 - "a"
                         0b0_00110_00, 0b101_01010,  # "a" - zchar5 - "e"
                         0b1_00101_11, 0b111_11111]) # zchar5 - "z" - "z"
    assert_equal("aAa2)z", Text.new(memory, 0).to_s)
  end
  
  def test_sequences_of_shift_chars_are_legal
    memory = Memory.new([0b1_00100_00, 0b101_11001])  # zchar4 - zchar5 - "t"
    assert_equal('"', Text.new(memory, 0).to_s)
  end
  
  def test_a_text_can_be_padded_with_shift_chars
    memory = Memory.new([0b1_00110_00, 0b101_00101]) # "a" - zchar5 - zchar5
    assert_equal("a", Text.new(memory, 0).to_s)
  end
  
  def test_zchar_0_is_a_space_and_resets_shifts
    memory = Memory.new([0b1_00100_00, 0b000_00110]) # zchar4 - zchar0 - "a"
    assert_equal(" a", Text.new(memory, 0).to_s)
  end
  
  def test_zchar_6_from_alphabet_2_encodes_arbitrary_zscii
    memory = Memory.new([0b0_00110_00, 0b101_00110,   # "a" - zchar5 - zchar6
                         0b1_00011_11, 0b011_00110])  # 0x7b (2 zchars) - "a"
    assert_equal("a{a", Text.new(memory, 0).to_s)
  end
  
  def test_incomplete_zchars_are_ignored
    memory = Memory.new([0b1_00101_00, 0b101_00110])   # zchar5 - zchar6 - 0xff
    assert_equal("", Text.new(memory, 0).to_s)
  end
end
