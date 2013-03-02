require 'spec'
require 'memory'

describe Rubyzza::Memory do
  before(:each) do
    @m = Rubyzza::Memory.new([0] * 0x5000)
  end
  
  it "should create word addresses" do
    @m.word(10000).should == 20000
  end
  
  it "should create packed addresses" do
    @m.packed(10000).should == 20000
  end

  it "should maintain global variables" do
    var_id = 0x12
    @m.write_global_var(var_id, 3.to_w)
    @m.read_global_var(var_id).unsigned.should == 3
    var_addr = Rubyzza::Memory::GLOBAL_VARS_BASE_ADDR + ((var_id - 0x10) * 2) + 1
    @m[var_addr].should == 3
    @m[var_addr] = 5
    @m.read_global_var(var_id).unsigned.should == 5
  end
  
  it "should read and write words" do
    addr = @m.word(0x1000)
    @m.write_word(addr, 7.to_w)
    @m.read_word(addr).unsigned.should == 7
    @m[addr + 1].should == 7
  end
  
  it "should raise an error when accessing out of memory" do
    # TODO
    #lambda { @m.write_word(@m.size, 0.to_w) }.should raise_error
    #lambda { @m.read_word(@m.size) }.should raise_error
  end
  
  it "should raise an error when accessing global variables out of range" do
    lambda { @m.write_global_var(-1, 9.to_w) }.should raise_error
    lambda { @m.read_global_var(0xff + 1) }.should raise_error
  end
end
