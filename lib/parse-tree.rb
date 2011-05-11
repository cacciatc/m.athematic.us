require File.dirname(__FILE__) + '/lexer'
require File.dirname(__FILE__) + '/utilities'
require File.dirname(__FILE__) + '/node'

class ParseTree
  include Lexer
  attr_accessor :root
  def initialize(list)
    #message needs to happen before reveal!
    infix_list = NegativeFun::massage_negative_numbers(list)
    infix_list = Implicit::reveal_the_multiplication(infix_list)
    prefix_list = FixToFix::infix_to_prefix(infix_list)
    @root,i = parse(prefix_list,0)
  end
  
  #convenience parse
  def parse(list,i)
    ParseTree.parse(list,i)
  end
  
  #parses a list of tokens and returns the root of a tree
  def self.parse(list,i)
    p = list[i]
    x = Node.new(p)
    if Node.operator?(p)
      x.l,i = ParseTree.parse(list,i+1)
      x.r,i = ParseTree.parse(list,i+1)
    end
    return x,i
  end
  
  #convenience count
  def count(node=@root)
    ParseTree.count(node)
  end
  
  #counts the number of nodes in a tree, starting at node
  def self.count(node)
    return 0 if node == nil
    return ParseTree.count(node.l) + ParseTree.count(node.r) + 1
  end
  
  #convenience height
  def height(node=@root)
    ParseTree.height(node)
  end
  
  #returns the height of a tree, starting at node
  def self.height(node)
    return -1 if node == nil
    u,v = ParseTree.height(node.l),ParseTree.height(node.r)
    return u > v ? u+1:v+1
  end
  
  #convenience traverse
  def traverse(node=@root,&b)
    ParseTree.traverse(node,&b)
  end
  
  #traverses a tree starting at node and yielding b upon visiting
  def self.traverse(node,&b)
    return nil if node == nil
    yield(node)
    ParseTree.traverse(node.l,&b)
    ParseTree.traverse(node.r,&b)
  end
  
  #convenience in order traversal
  def inorder_traverse(node=@root,&b)
    ParseTree.inorder_traverse(node,&b)
  end
  
  #in order traversal of a tree starting at node and yielding b upon visiting
  def self.inorder_traverse(node,&b)
    return nil if node == nil
    ParseTree.inorder_traverse(node.l,&b)
    yield(node)
    ParseTree.inorder_traverse(node.r,&b)
  end
  
  #hackish way to get infix pretty print, this will eventually be punted out to another module
  def infix(node=@root,&b)
    return nil if node == nil
    @s += "(" if node.operator? and not node.sym =~ EQUALS
    infix(node.l,&b)
    yield(node)
    infix(node.r,&b)
    @s += ")" if node.operator?  and not node.sym =~ EQUALS
  end
  
  alias :preorder_traverse :traverse
  
  #like infix above it, this logic will eventually move out to a pretty print class!
  def to_s(fix=:prefix)
    @s = ""
    case fix
      when :prefix
        preorder_traverse do |node|
          @s += "#{node} "
        end
        @s.chop!
      when :infix
        infix(@root) do |node|
          @s += "#{node}"
        end
        #parenthesis cleaning
        left,right = @s.split('=')
        if left[0] == '(' and left[-1] == ')'
          left = left[1..-2] 
        end
        if right[0] == '(' and right[-1] == ')'
          right = right[1..-2] 
        end
        @s = "#{left}=#{right}"
      when :tex
        infix(@root) do |node|
          @s += "#{node}"
        end
        left,right = @s.split('=')
        if left[0] == '(' and left[-1] == ')'
          left = left[1..-2] 
        end
        if right[0] == '(' and right[-1] == ')'
          right = right[1..-2] 
        end
        @s = "$#{left}=#{right}$"
    end
    @s
  end
end