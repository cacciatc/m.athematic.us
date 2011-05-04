require 'lexer'
require 'annotator'
require 'utilities'

module T2Solver
  include Lexer
  
  class Node
    include T2Solver
    attr_accessor :sym,:l,:r
    def initialize(sym,l=nil,r=nil)
      @sym,@l,@r = sym,l,r
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
          @sym = '*' #unless @r.sym =~ VARIABLE
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
  
  class ParseTree
    include T2Solver
    def initialize(list)
      @root = nil
      @root,i = parse(FixToFix::infix_to_prefix(list),0)
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
          #parenthesis cleaning
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
  
  class Solver < ParseTree
    def initialize(list)
      @a = Annotator.new
      super(Lexer.scan!(list))
    end
    #generally we only eval the right, since the left has unknown(s)
    def eval(node=@root.r)
      return nil if node == nil
      if OPERATORS =~ node.sym
        node.proc(eval(node.l),eval(node.r))
      else
        node.proc
      end
    end
    def reduce!(node=@root.r)
      return nil if node == nil
      if OPERATORS =~ node.sym
        a,b = reduce!(node.l),reduce!(node.r)
        @a.annotate(to_s(:tex))
        @a.queue_note(node.desc)
        v = node.proc(a,b)
        node.sym = v.to_s
        node.l,node.r = nil,nil
        v
      else
        node.proc
      end
    end
    #tries to remove everything, but the x on the left
    def isolate
      @path = []
      node = path_to(VARIABLE)
      @path.pop
      @path.reverse!
      
      if @path.size > 1
        #swap node that is in the path with the other side of the root
        @path[0..@path.size-2].each_with_index do |p,i|
          if @root.r == p
            subtree = @root.l
            @root.l = p
            @root.r = @path[i+1]
            return if @path[i+1] == nil
            if p.l == @path[i+1]
              p.l = subtree
            else
              p.r = subtree
              #special case so we don't have to redo isolation
              if p.sym =~ DIVISION
                p.l,p.r = p.r,p.l
                @root.l.r = Node.new('1') if @root.l.r.nil?
                @root.l.l = Node.new('1') if @root.l.l.nil?
                @root.l.r,@root.l.l = @root.l.l,@root.l.r
                next
              end
            end
          else
            subtree = @root.r
            @root.r = p
            @root.l = @path[i+1]
            return if @path[i+1] == nil
            if p.l == @path[i+1]
              p.l = subtree
            else
              p.r = subtree
              #special case so we don't have to redo isolation
              if p.sym =~ DIVISION
                p.l,p.r = p.r,p.l
                @root.r.r = Node.new('1') if @root.r.r.nil?
                @root.r.l = Node.new('1') if @root.r.l.nil?
                @root.r.r,@root.r.l = @root.r.l,@root.r.r
                next
              end
            end
          end
          p.invert!
          #work should be noted here!
          @a.queue_note(p.desc)
          @a.annotate(to_s(:tex))
        end
      end
      if @root.r == node
        @a.queue_note('transposition')
        @root.r,@root.l = @root.l,@root.r 
      end
    end
    def path_to(r,node=@root)
      return p if node == nil
      if node.sym =~ r
        @path << node
        return node 
      end
      n = path_to(r,node.l) || path_to(r,node.r)
      @path << node if n
      return n
    end
    #to make sure VARIABLES are always are on the left subtree of its parent node
    #modifying the tree mid-traversal...be there a better way?
    def fixr!(node)
      return nil if node == nil
      fixr!(node.r)
      @var_found = (node.sym =~ VARIABLE) != nil || @var_found
      if @var_found and (node.sym == '+' or node.sym == '*')
        node.l,node.r = node.r,node.l
        node = node.l
      end
      fixr!(node.l)
    end
    def solve!()
      #internal house-keeping so order of ops work
      @var_found = false
      fixr!(@root.r)
      @var_found = false
      fixr!(@root.l)
      
      @a.annotate(to_s(:tex),'original problem')
      isolate
      reduce!
      
      #the answer!
      @a.annotate(to_s(:tex))
      @a.purge_empty_notes!
      
      #the right of the root contains the answer
      @root.r.sym
    end
    def work
      @a.w
    end
    private :fixr!,:isolate,:eval
  end
end