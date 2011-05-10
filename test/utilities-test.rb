require File.dirname(__FILE__) + '/../lib/utilities'
require File.dirname(__FILE__) + '/../lib/lexer'
require 'rspec'

describe "Utilities" do
  it "should know what -(x+1) means" do
    NegativeFun::massage_negative_numbers(Lexer.scan!('-(x+1)')).should == ['-1.0','(','x','+','1',')']
  end
  it "should know what -10 means" do
    NegativeFun::massage_negative_numbers(Lexer.scan!('-10')).should == ['-10.0']
  end
  it "should know what -x means" do
    NegativeFun::massage_negative_numbers(Lexer.scan!('-x')).should == ['-1.0','x']
  end
end