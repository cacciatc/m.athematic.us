require File.dirname(__FILE__) + '/lexer'

class ParseTree
  include Lexer
  def initialize(list)
    @root = nil
    list = Implicit::reveal_the_multiplication(list)
    list = FixToFix::infix_to_prefix(list)
    @root,i = parse(list,0)
  end
  def parse(list,i)
    p = list[i]
    x = Node.new(p)
    if OPERATORS =~ p
      x.l,i = parse(list,i+1)
      x.r,i = parse(list,i+1)
    end
    return x,i
  end
  def count(node=@root)
    return 0 if node == nil
    return count(node.l) + count(node.r) + 1
  end
  
  def height(node=@root)
    self.height(node)
  end
  def self.height(node)
    return -1 if node == nil
    u,v = height(node.l),height(node.r)
    return u > v ? u+1:v+1
  end
  
  def traverse(node=@root,&b)
    return nil if node == nil
    yield(node)
    traverse(node.l,&b)
    traverse(node.r,&b)
  end
  def inorder_traverse(node=@root,&b)
    return nil if node == nil
    inorder_traverse(node.l,&b)
    yield(node)
    inorder_traverse(node.r,&b)
  end
  def infix(node=@root,&b)
    return nil if node == nil
    @s += "(" if node.sym =~ OPERATORS and not node.sym =~ EQUALS
    infix(node.l,&b)
    yield(node)
    infix(node.r,&b)
    @s += ")" if node.sym =~ OPERATORS and not node.sym =~ EQUALS
  end
  alias :preorder_traverse :traverse
  def to_s(fix=:prefix)
    @s = ""
    case fix
      when :prefix
        preorder_traverse do |node|
          @s += "#{node} "
        end
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
  private :parse,:infix
end