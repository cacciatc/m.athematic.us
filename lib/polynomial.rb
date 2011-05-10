require File.dirname(__FILE__) + '/../lib/parse-tree'
require File.dirname(__FILE__) + '/../lib/lexer'

module Polynomial
  POSITIVE_INTEGER = /[0-9]+/
  def self.is_a_poly?(tree)
    only_positive_integer_exponents?(tree) and no_variables_in_denominator?(tree) 
  end
  
  def self.only_positive_integer_exponents?(tree)
    ParseTree.traverse(tree) do |node|
      return false if node.sym =~ Lexer::EXPONENTIATION and not node.r.sym =~ POSITIVE_INTEGER
    end
    true
  end
  
  def self.no_variables_in_denominator?(tree)
    ParseTree.traverse(tree) do |node|
      return false if node.sym =~ Lexer::DIVISION and node.r.sym =~ Lexer::VARIABLE
    end
    true
  end
end