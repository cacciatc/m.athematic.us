require File.dirname(__FILE__) + '/lexer'
require File.dirname(__FILE__) + '/node'
require File.dirname(__FILE__) + '/parse-tree'

module Algebraic
  include Lexer
  def self.complete_family?(node)
    if node.nil? or node.l.nil? or node.r.nil?
      false
    else
      true
    end
  end
  def self.distribute!(node)
    return if not complete_family?(node) or not node.sym =~ MULTIPLICATON
    if ParseTree::height(node.r) > ParseTree::height(node.l) 
      #(b+c)a
      return if not complete_family?(node.l) or node.l.sym =~ ADDITION or node.l.sym =~ SUBTRACTION
      a,b,c = node.r,node.l.l,node.l.r
      b_x_a = Node.new('*',b,a)
      c_x_a = Node.new('*',c,a)
      node.sym = Node.new('+',b_x_a,c_x_a)
    else
      #a(b+c)
      return if not complete_family?(node.r) or node.l.sym =~ ADDITION or node.l.sym =~ SUBTRACTION
      a,b,c = node.l,node.r.l,node.r.r
      a_x_b = Node.new('*',a,b)
      a_x_c = Node.new('*',a,c)
      node.sym = Node.new('+',a_x_b,a_x_c)
    end
    node
  end
  def self.distributive?(node)
    return false if not complete_family?(node) or not node.sym =~ ADDITION
    return false if not complete_family?(node.r) or not complete_family?(node.l)
    return false if not node.r.sym =~ MULTIPLCIATION or not node.r.sym =~ MULTIPLICATION
    #ab + cd
    a,b,c,d = node.l.l,node.l.r,node.r.l,node.r.r
    return false if a.sym != c.sym or b.sym != d.ym
    true
  end
  def self.additive_identity!(node,subtree)
    node = Node.new('+')
    node.l = subtree
    node.r = Node.new('0')
    node
  end
  def self.additive_identity?(node)
    return false if not complete_family?(node)
    if node.sym =~ ADDITION and (node.l.smy == '0' or node.r.sym == '0')
      true
    else
      false
    end
  end
  def self.multiplicative_identity!(node,subtree)
    node = Node.new('*')
    node.l = subtree
    node.r = Node.new('1')
    node
  end
  def self.multiplicative_identity?(node,subtree)
    return false if not complete_family?(node)
    if node.sym =~ MULTIPLICATION and (node.l.smy == '1' or node.r.sym == '1')
      true
    else
      false
    end
  end
end