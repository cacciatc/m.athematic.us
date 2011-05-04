require 'lexer'
module FixToFix
  include Lexer
  PRIORITY = {}
  PRIORITY.default = 0
  PRIORITY['='] = 1
  PRIORITY['+'] = 2
  PRIORITY['-'] = 2
  PRIORITY['*'] = 3
  PRIORITY['/'] = 3

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