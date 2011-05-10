require File.dirname(__FILE__) + '/lexer'
module FixToFix
  include Lexer
  PRIORITY = {}
  PRIORITY.default = 0
  PRIORITY['='] = 1
  PRIORITY['+'] = 2
  PRIORITY['-'] = 2
  PRIORITY['*'] = 3
  PRIORITY['/'] = 3
  PRIORITY['^'] = 3

  def self.infix_to_prefix(list)
    prefix,s  = [],[]
      list.reverse.each do |i|
      case i
        when RPAREN
          s.push(i)
        when LPAREN
          while s.last != ')'
            prefix.push(s.pop)
          end
          s.pop
        when OPERATORS
          while PRIORITY[s.last] > PRIORITY[i]
            prefix.push(s.pop)
          end
          s.push(i)
        else
          prefix.push(i)
      end
    end
    until s.empty?
      prefix.push(s.pop)
    end
    prefix.reverse
  end
end

module Implicit
  include Lexer
  #expects a list in infix
  def self.reveal_the_multiplication(list)
    i = 0
    todo = []
    while i+1 < list.length
      a,b = list[i],list[i+1]
      if a =~ EQUALS or b =~ EQUALS
        a,b = list[i+1],list[i+2]
        i += 1
        next
      end
      if b =~ LPAREN and not a =~ OPERATORS
        todo.push([i+1,'*'])
      end
      if b =~ VARIABLE and a =~ NUMBER
        todo.push([i+1,'*'])
      end
      i += 2
    end

    i = 0
    todo.each do |t|
      list.insert(t[0]+i,t[1])
      i += 1
    end
    list
  end
  #expects a list in infix
  def self.implicit_the_multiplication(list)
    i = 0
    todo = []
    list.each_slice(2) do |a,b|
      if b =~ LPAREN and a =~ MULTIPLICATION
        todo.push(i)
      end
      if b =~ VARIABLE and a =~ MULTIPLICATION
        todo.push(i)
      end
      if a =~ VARIABLE and b =~ MULTIPLICATION
        todo.push(i+1)
      end
      i += 2
    end
    i = 0
    todo.each do |t|
      list.delete_at(t-i)
      i += 1
    end
    list
  end
end