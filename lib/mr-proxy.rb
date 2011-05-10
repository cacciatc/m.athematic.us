require File.dirname(__FILE__) + '/t2-solver'
require File.dirname(__FILE__) + '/polynomial'

class MrProxy
  SIMPLIFY = /simplify/i
  FACTOR   = /factor/i
  COMMANDS = Regexp.union(SIMPLIFY,FACTOR)
  def initialize(p)
    @p = p
  end
  def self.what_should_i_do(string)
    flags = []
    string.scan(COMMANDS) do |w|
      case w
        when SIMPLIFY
          flags.push(:simplify)
        when FACTOR
          flags.push(:factor)
      end
    end
    tokens = Lexer.scan!(string)
    todo = Proc.new do
      raise "This problem is harder than we thought.  Maybe leave some feedback?"
    end
    t = ParseTree.new(tokens).root
    
    if tokens.include?('=')
      #might be able to solve it
      if Polynomial::is_a_poly?(t.l) and Polynomial::is_a_poly?(t.r)
        todo = Proc.new do
          s = T2Solver::Solver.new(tokens)
          s.solve!
          s
        end
      else
        #something else that we are not going to worry about just yet like rationals
      end
    else
      if Polynomial::is_a_poly?(t)
        if flags.include?(:simplify) and flags.include?(:factor)
          todo = Proc.new do
            s = T2Solver::Solver.new(tokens)
            s.simplify!
            s.factor!
            s
          end
        else
          if flags.include?(:simplify)
            todo = Proc.new do
              s = T2Solver::Solver.new(tokens)
              s.simplify!
              s
            end
          elsif flags.include?(:factor)
            todo = Proc.new do
              s = T2Solver::Solver.new(tokens)
              s.factor!
              s
            end
          end
        end
      end
    end
    MrProxy.new(todo)
  end
  def well_do_it!
    @p.call(self)
  end
end