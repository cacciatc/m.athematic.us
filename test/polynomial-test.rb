require File.dirname(__FILE__) + '/../lib/polynomial'
require File.dirname(__FILE__) + '/../lib/parse-tree'
require File.dirname(__FILE__) + '/../lib/lexer'
require 'rspec'

describe Polynomial do
  it "should know 10x-(2x+(13-4x)-(11-3x))+(2x+5) is a polynomial" do
    tree = ParseTree.new(Lexer.scan!('10x-(2x+(13-4x)-(11-3x))+(2x+5)')).root
    Polynomial::is_a_poly?(tree).should == true
  end
  
  it "should know that 10/x is not a polynomial" do
    tree = ParseTree.new(Lexer.scan!('10/x')).root
    Polynomial::is_a_poly?(tree).should == false
  end
  
  it "should know that 10x-(2x+(13-4x^(-2))-(11-3x))+(2x+5) is not a polynomial" do
    tree = ParseTree.new(Lexer.scan!('10x-(2x+(13-4x^(-2))-(11-3x))+(2x+5)')).root
    Polynomial::is_a_poly?(tree).should == false
  end
    
  it "should know that 10x-(2x+(13-4x^(3/2))-(11-3x))+(2x+5) is not a polynomial" do
    tree = ParseTree.new(Lexer.scan!('10x-(2x+(13-4x^(3/2))-(11-3x))+(2x+5)')).root
    Polynomial::is_a_poly?(tree).should == false
  end
end