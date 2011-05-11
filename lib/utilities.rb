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
  PRIORITY['^'] = 4

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
        when REAL_NUMBER
          prefix.push(i)
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

module NegativeFun
  include Lexer
  #expects a list in infix
  def self.massage_negative_numbers(list)
    return list if list.size < 2
    list.each_with_index do |t,i|
      if t == '-'
        if i == 0 or list[i-1] =~ OPERATORS or list[i-1] == '('
          raise "This expression has a dangling minus sign #{list[0..i].join(" ")}" if list.size < i+1
          #negative number!
          case list[i+1]
            when NUMBER
              list[i] = nil
              list[i+1] = (list[i+1].to_f*-1).to_s
            when /\(/
              list[i] = (-1.0).to_s
            when VARIABLE
              list[i] = (-1.0).to_s
          end
        end
      end
    end
    list.delete_if {|l| l.nil?}
    list
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
      if b =~ LPAREN and a =~ REAL_NUMBER
        todo.push([i+1,'*'])
      end
      if b =~ VARIABLE and a =~ REAL_NUMBER
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