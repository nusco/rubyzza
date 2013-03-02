require 'spec'
require 'zspec'
require '../lib/word'

describe Rubyzza::Word do
  Z.spec '2.1'
  it "should convert from two bytes" do
    w = [27, 99].to_w
    [w.msb, w.lsb].should == [27, 99]
  end

  it "should behave as an array" do
    w = [27, 99].to_w
    [w[0], w[1]].should == [27, 99]
  end

  Z.spec '2.1'
  it "should fail to convert any number of bytes different than two" do
    lambda{ [27].to_w }.should raise_error
    lambda{ [27, 99, 12].to_w }.should raise_error
  end

  Z.spec '2.3' # Arithmetic errors

  Z.spec '2.3.1'
  it "should not be divisable by zero" do
    lambda {
      123456.to_w.unsigned / 0
    }.should raise_error
  end

  Z.spec '2.3.2'
  it "should clip out of range calculations to two bytes" do
    123456.to_w.unsigned.should == 57920
    -123456.to_w.unsigned.should == -57920
  end

  it "should convert to another word" do
    w = 32767.to_w
    w.to_w.should == w
  end

  Z.spec '2.2' # Signed Operations

  Z.spec '2.2.1'
  it "should convert from a positive integer" do
    w = 32767.to_w
    [w.msb, w.lsb].should == [0b01111111, 255]
  end

  Z.spec '2.2.1'
  it "should convert from a negative integer" do
    w = -32768.to_w
    [w.msb, w.lsb].should == [0b10000000, 0]
  end
  
  Z.spec '2.2.1'
  it "should convert to an unsigned integer" do
    [1, 5].to_w.unsigned.should == 261
  end

  Z.spec '2.2.1'
  it "should convert to a signed integer" do
    [0, 0].to_w.signed.should == 0
    [255, 255].to_w.signed.should == -1
    [255, 0b11111011].to_w.signed.should == -5
    [0b01111111, 255].to_w.signed.should == 32767
    [0b10000000, 0].to_w.signed.should == -32768
  end

  it "should support equality" do
    [0, 3].to_w.should == 3.to_w
  end
    
  it "should check single bits" do
    [0b10000000, 0].to_w.bits(0).should == 0
    [0b10000000, 0].to_w.bits(15).should == 1
  end
  
  it "should convert to bits" do
    [255, 0b10001010].to_w.bits(1..3).should == 5  # 0b101
  end
  
  it "should convert to a string of bits" do
    [0b01, 0b10001010].to_w.to_s.should == '0000000110001010'
  end
end

Z.report
