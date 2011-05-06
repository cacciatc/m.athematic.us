require 'algebra'
require 'parse-tree'
require 'rspec'

describe "Algebra" do
  it "should have cross multiplying!" do
    a,b,c,d = Node.new('1'),Node.new('2'),Node.new('4'),Node.new('8')
    a_b,c_d = Node.new('/',a,b),Node.new('/',c,d)
    tree = Node.new('=',a_b,c_d)
    tree = Algebraic::cross_multiply(tree)
    $output = ""
    ParseTree::inorder_traverse(tree){|n| $output+="#{n}"}
    $output.should =='1*8=2*4'
  end
  it "should have cross multiplying even when not explicit!" do
    a,c,d = Node.new('8'),Node.new('16'),Node.new('2')
    c_d = Node.new('/',c,d)
    tree = Node.new('=',a,c_d)
    tree = Algebraic::cross_multiply(tree)
    $output = ""
    ParseTree::inorder_traverse(tree){|n| $output+="#{n}"}
    $output.should =='8*2=1*16'
  end
end