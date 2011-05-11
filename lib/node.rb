class Node
  #nodes have to use slightly different operator regex's
  INTEGER = /(\-|\+|)([0-9]+|[0-9]+\.[0-9]+)/
  REAL    = /[0-9]+\.[0-9]+/
  NUMBER  = Regexp.union(REAL,INTEGER)  
  
  EQUALS      = /\=/
  ADDITION    = /^\+$/
  SUBTRACTION = /^\-$/
  MULTIPLICATION = /\*/
  DIVISION       = /\//
  EXPONENTIATION = /\^/

  OPERATORS = Regexp.union(
    EQUALS,ADDITION,SUBTRACTION,DIVISION,MULTIPLICATION,
    EXPONENTIATION
  )
  
  attr_accessor :sym,:l,:r
  def initialize(sym,l=nil,r=nil)
    @sym,@l,@r = sym,l,r
  end
  def self.operator?(sym)
    sym =~ OPERATORS
  end
  def operator?
    Node.operator?(@sym)
  end
  def proc(*args)
    case @sym
      when ADDITION
        return args[0]+args[1]
      when SUBTRACTION
        return args[0]-args[1]
      when MULTIPLICATION
        return args[0]*args[1]
      when DIVISION
        return args[0]/args[1]
      when EXPONENTIATION
        return args[0]**args[1]
      when NUMBER
        return @sym.to_f
    end
  end
  def invert!
    case @sym
      when ADDITION
        @sym = '-'
      when SUBTRACTION
        @sym = '+'
      when MULTIPLICATION
        @sym = '/'
      when DIVISION
        @sym = '*'
    end
    self
  end
  def to_s
    @sym
  end
  def desc
    case @sym
      when ADDITION
        "addition"
      when SUBTRACTION
        "subtraction"
      when MULTIPLICATION
        "multiplication"
      when DIVISION
        "division"
    end
  end
  def details
    "#{@sym} #{@l} #{@r}"
  end
end