require File.dirname(__FILE__) + '/../lib/parse-tree'
require File.dirname(__FILE__) + '/../lib/lexer'
require 'rspec'

describe ParseTree do
  it "should be able to represent a constant polynomial" do
    ParseTree.new(['2','*','(','1','+','2',')']).to_s.should == '* 2 + 1 2'
  end
  it "should be able to represent a linear polynomial" do
    ParseTree.new(['x','*','(','1','+','2',')']).to_s.should == '* x + 1 2'
  end
  it "should be able to represent a quadratic polynomial" do
    ParseTree.new(['x','^','2','+','2']).to_s.should == '+ ^ x 2 2'
  end
  it "should be able to represent rationals" do
    ParseTree.new(['2','/','x','+','2']).to_s.should == '+ / 2 x 2'
  end
  it "should be able to represent equations" do
    ParseTree.new(['x','^','2','+','2','=','4']).to_s.should == '= + ^ x 2 2 4'
  end
  it "should be able to parse 10x-(2x+(13-4x)-(11-3x))+(2x+5) (issue 34)" do
    ParseTree.new(Lexer.scan!('10x-(2x+(13-4x)-(11-3x))+(2x+5)')).to_s.should == '+ - * 10 x - + * 2 x - 13 * 4 x - 11 * 3 x + * 2 x 5'
  end
  it "should be able to parse -(10[x+1]-(4x)) (issue 32)" do
    ParseTree.new(Lexer.scan!('-(10[x+1]-(4x))')).to_s.should == '* -1.0 - * 10 + x 1 * 4 x'
  end
end
