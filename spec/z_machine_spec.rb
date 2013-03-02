require 'rspec'
require_relative '../rubyzza'

describe Rubyzza::ZMachine do
  before(:each) do
    @zm = Rubyzza::ZMachine.new
    @zm.mem = [0] * 0x5000
  end
  
  it "should create word addresses" do
    @zm.word(10000).should == 20000
  end
  
  it "should create packed addresses" do
    @zm.packed(10000).should == 20000
  end
  
  it "should read and write words" do
    addr = @zm.word(0x1000)
    @zm.w_word(addr, 7.to_w)
    @zm.r_word(addr).unsigned.should == 7
    @zm.mem[addr + 1].should == 7
  end
end
