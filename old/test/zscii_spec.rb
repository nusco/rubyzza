require 'spec'
require '../lib/zscii'

describe Rubyzza::ZSCII do
  before :each do
    @zscii = Rubyzza::ZSCII.new
  end
  
  it 'test_undefined_characters_have_no_output' do
    @zscii[154].should == ''
  end
  
  it 'test_char_zero_is_null_output' do
    @zscii[0].should == ''
  end
  
  it 'test_char_13_is_newline' do
    @zscii[13].should == '\n'
  end
  
  it 'test_chars_from_32_to_126_agree_with_ASCII' do
    @zscii[32].should == ' '
    @zscii[123].should == '{'
  end
  
  it 'test_encodes_characters_into_ZSCII' do
    @zscii.encode('{').should == 123
  end

  it 'test_supports_unicode' do
    @zscii[223].should == 191.chr
  end

# check for encoding of character w/o a zscii equivalent
end
