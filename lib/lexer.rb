module Lexer
  REAL_NUMBER = /(\-|\+|)([0-9]+|[0-9]+\.[0-9]+)/
  INTEGER = /[0-9]+/
  REAL    = /[0-9]+\.[0-9]+/
  NUMBER  = Regexp.union(REAL,INTEGER)
  
  VARIABLE = /[a-z]+/i
  IDENTIFIERS = Regexp.union(NUMBER,VARIABLE)
  
  EQUALS      = /\=/
  ADDITION    = /\+/
  SUBTRACTION = /\-/
  MULTIPLICATION = /\*/
  DIVISION       = /\//
  EXPONENTIATION = /\^/
  LPAREN    = /\(/
  RPAREN    = /\)/
  OPERATORS = Regexp.union(
    EQUALS,ADDITION,SUBTRACTION,DIVISION,MULTIPLICATION,
    EXPONENTIATION,LPAREN,RPAREN
  )

  LOG  = Regexp.new("/log#{LPAREN}#{IDENTIFIERS}#{RPAREN}/i")
  LN   = Regexp.new("/ln#{LPAREN}#{IDENTIFIERS}#{RPAREN}/i")
  LG   = Regexp.new("/lg#{LPAREN}#{IDENTIFIERS}#{RPAREN}/i")
  LOGB = Regexp.new("#{LOG}_#{IDENTIFIERS}#{LPAREN}#{IDENTIFIERS}#{RPAREN}")
  FUNCTIONS = Regexp.union(LOG,LN,LG,LOGB)
  
  LANG = Regexp.union(IDENTIFIERS,OPERATORS,FUNCTIONS)
  def self.scan!(expr)
    expr.scan(LANG) 
  end
end