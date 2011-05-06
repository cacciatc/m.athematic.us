require File.dirname(__FILE__) + '/lexer'
require File.dirname(__FILE__) + '/node'
require File.dirname(__FILE__) + '/parse-tree'

module Algebraic
  include Lexer
  def self.complete_family?(operation_node)
    if operation_node.nil? or operation_node.l.nil? or operation_node.r.nil?
      false
    else
      true
    end
  end
  def self.distribute!(operation_node)
    return operation_node if not complete_family?(operation_node) or not operation_node.sym =~ MULTIPLICATON
    if ParseTree::height(operation_node.r) > ParseTree::height(operation_node.l) 
      #(b+c)a
      return operation_node if not complete_family?(operation_node.l) or operation_node.l.sym =~ ADDITION or operation_node.l.sym =~ SUBTRACTION
      a,b,c = operation_node.r,operation_node.l.l,operation_node.l.r
      b_x_a = Node.new('*',b,a)
      c_x_a = Node.new('*',c,a)
      operation_node.sym = Node.new('+',b_x_a,c_x_a)
    else
      #a(b+c)
      return operation_node if not complete_family?(operation_node.r) or operation_node.l.sym =~ ADDITION or operation_node.l.sym =~ SUBTRACTION
      a,b,c = operation_node.l,operation_node.r.l,operation_node.r.r
      a_x_b = Node.new('*',a,b)
      a_x_c = Node.new('*',a,c)
      operation_node.sym = Node.new('+',a_x_b,a_x_c)
    end
    operation_node
  end
  def self.distributive?(operation_node)
    return false if not complete_family?(operation_node) or not operation_node.sym =~ ADDITION
    return false if not complete_family?(operation_node.r) or not complete_family?(operation_node.l)
    return false if not operation_node.r.sym =~ MULTIPLCIATION or not operation_node.r.sym =~ MULTIPLICATION
    #ab + cd
    a,b,c,d = operation_node.l.l,operation_node.l.r,operation_node.r.l,operation_node.r.r
    return false if a.sym != c.sym or b.sym != d.sym
    true
  end
  def self.additive_identity!(identifier_node,subtree)
    identifier_node = Node.new('+')
    identifier_node.l = subtree
    identifier_node.r = Node.new('0')
    identifier_node
  end
  def self.additive_identity?(operation_node)
    return false if not complete_family?(operation_node)
    if operation_node.sym =~ ADDITION and (operation_node.l.sym == '0' or operation_node.r.sym == '0')
      true
    else
      false
    end
  end
  def self.multiplicative_identity!(identifier_node,subtree)
    identifier_node = Node.new('*')
    identifier_node.l = subtree
    identifier_node.r = Node.new('1')
    identifier_node
  end
  def self.multiplicative_identity?(operation_node,subtree)
    return false if not complete_family?(operation_node)
    if operation_node.sym =~ MULTIPLICATION and (operation_node.l.sym == '1' or operation_node.r.sym == '1')
      true
    else
      false
    end
  end
  def self.over_one(identifier_node)
    return identifier_node if identifier_node.nil?
    #a = a/1
    identifier_node = Node.new('/',identifier_node,Node.new('1'))
    identifier_node
  end
  def self.cross_multiply(equals_node)
    return equals_node if equals_node.nil? or not equals_node.sym =~ EQUALS
    return equals_node if not complete_family?(equals_node)
    
    #a/b = c/d => ad = bc
    if not equals_node.r.sym =~ DIVISION
      equals_node.r = over_one(equals_node.r)
    end
    if not equals_node.l.sym =~ DIVISION
      equals_node.l = over_one(equals_node.l)
    end
    a,b,c,d = equals_node.l.l,equals_node.l.r,equals_node.r.l,equals_node.r.r
    equals_node.l = Node.new('*',a,d)
    equals_node.r = Node.new('*',b,c)
    equals_node
  end
end