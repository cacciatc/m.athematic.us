require File.dirname(__FILE__) + '/../lib/parse-tree'
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
end
