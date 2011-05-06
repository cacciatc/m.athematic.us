require File.dirname(__FILE__) + '/lexer'
require File.dirname(__FILE__) + '/annotator'
require File.dirname(__FILE__) + '/utilities'
require File.dirname(__FILE__) + '/algebra'
require File.dirname(__FILE__) + '/node'
require File.dirname(__FILE__) + '/parse-tree'

module T2Solver
  include Lexer
  
  class Path
    attr_accessor :paths,:visited
    def initialize
      @paths,@visited = [],[]
    end
    def path!(r,node)
      @paths = []
      @visited = []
      while path_to(r,node)
      end
    end
    def path_to(r,node)
      return p if node == nil
      if node.sym =~ r and not @visited.include?(node)
        @paths << node
        @visited << node
        return node 
      end
      n = path_to(r,node.l) || path_to(r,node.r)
      @paths << node if n
      return n
    end
    def to_s
      "#{@paths.join("\n")}"
    end
    private :path_to
  end
  
  class Solver < ParseTree
    attr_accessor :p
    def initialize(list)
      @a = Annotator.new
      @p = Path.new
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
    def unravel_to_otherside(path)
      path.pop
      path.reverse!
      
      if path.size > 1
        #swap node that is in the path with the other side of the root
        path[0..path.size-2].each_with_index do |p,i|
          if @root.r == p
            subtree = @root.l
            @root.l = p
            @root.r = path[i+1]
            return if path[i+1] == nil
            if p.l == path[i+1]
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
            @root.l = path[i+1]
            return if path[i+1] == nil
            if p.l == path[i+1]
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
    end
    #tries to remove everything, but the x on the left
    def isolate
      @p.path!(VARIABLE,@root)
      if @p.paths.empty?
        raise "No variable found in the expression."
      end
      path = @p.paths
      unravel_to_otherside(path)
      
      if @root.r == (variable_node=@p.visited.first)
        @a.queue_note('transposition')
        @root.r,@root.l = @root.l,@root.r 
      end
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
      combine_like_terms!
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
    
    #tries to combine like terms, currently only work for single variable expressions
    def combine_like_terms!
      path(VARIABLE)
      if @p.paths.empty?
        raise "No variable found in the expression."
      end
      #only one variable, so no work to be done
      if @p.paths.count {|i| i.sym =~ EQUALS} == 1
        return
      else
        var_paths = []
        var_paths.push([])
        i = 0
        @p.paths.each do |p|
          var_paths[i].push(p)
          if p.sym =~ EQUALS
            var_paths.push([])
            i += 1
          end
        end
        #remove the empty path at the end
        var_paths.pop
        
        #determine if they are combinable
        var = var_paths.first.first
        result = var_paths.detect do |p|
          var != p.first
        end
        if not result
          raise 'Multi-variable equations are currently not supported.'
        end
        
        right,left = [],[]
        level1 = -2
        var_paths.each do |p|
          if p[level1] == @root.r
            right.push(p)
          else
            left.push(p)
          end
        end
        if left.size < right.size
          #move all variables to the right
          left.each do |l|
            #special case where the variable is all alone
            if l.size == 2
              equals,variable = l.last,l.first
              equals.l = Algebraic::additive_identity!(equals.l,variable)
              #swap the operands if need be so that they are applied correctly on the other side
              equals.l.r,equals.l.l = equals.l.l,equals.l.r if equals.r.sym =~ ADDITION or equals.r.sym =~ MULTIPLICATION
              l.insert(1,equals.l)
            end
            #we want to isolate x's partner instead of x
            l[0] = l[1].r.sym =~ VARIABLE ? l[1].l : l[1].r
            unravel_to_otherside(l)
          end
        else
          #move all variables to the left
          right.each do |r|
            #special case where the variable is all alone
            if r.size == 2
              equals,variable = r.last,r.first
              equals.r = Algebraic::additive_identity!(equals.r,variable)
              #swap the operands if need be so that they are applied correctly on the other side
              equals.r.r,equals.r.l = equals.r.l,equals.r.r if equals.r.sym =~ ADDITION or equals.r.sym =~ MULTIPLICATION
              r.insert(1,equals.r)
            end
            #we want to isolate x's partner instead of x
            r[0] = r[1].r.sym =~ VARIABLE ? r[1].l : r[1].r
            unravel_to_otherside(r)
          end
        end
        
        #now finally combine what we can!
        path(VARIABLE)
        
        var_paths = []
        var_paths.push([])
        i = 0
        @p.paths.each do |p|
          var_paths[i].push(p)
          if p.sym =~ EQUALS
            var_paths.push([])
            i += 1
          end
        end
        #remove the empty path at the end
        var_paths.pop
        
        sum = 0.0
        max_coef = 0
        coefficient_node     = var_paths.first[1]
        winner_variable_node = var_paths.first.first
        
        var_paths.each do |p|
          coef = calculate_coefficient(p)
          variable = p.first
          if coef > max_coef
            max_coef = coef
            coefficient_node     = (p[1].l == variable ? p[1].r : p[1].l)
            winner_variable_node = (p[1].l == variable ? p[1].l : p[1].r)
          end
          sum += coef
        end
        if sum == 0.0
          raise "Unsolvable equation.  The variable's coefficient is zero."
        end
        #change the variable with the largest coefficient
        update(coefficient_node,"#{sum}",@root)
        
        #remove other variable instances from the tree
        var_paths.each do |node_in_path|
          if node_in_path.first != winner_variable_node
            remove_node(node_in_path.first)
          end
        end
        prune_operations_with_nils!
        @a.annotate(to_s(:infix),'combine like terms')
      end
    end
    def remove_node(node_to_remove,node=@root)
      return nil if node.nil? or node.r.nil? or node.l.nil?
      if node.l == node_to_remove
        node.l = nil
        node = node.r
        return
      elsif node.r == node_to_remove
        node.r = nil
        node = node.l
        return
      end
      remove_node(node_to_remove,node.l)
      remove_node(node_to_remove,node.r)
    end
    def update(node_to_update,new_sym,node)
      return nil if node.nil?
      if node_to_update == node
        node_to_update.sym = new_sym
      end
      update(node_to_update,new_sym,node.l)
      update(node_to_update,new_sym,node.r)
    end
    def prune_operations_with_nils!(node=@root,parent=@root)
      return nil if node.sym =~ IDENTIFIERS or node.nil?
      if node.l == nil
        parent.r = node.r
        node = nil
        prune_operations_with_nils!(parent.l,parent)
        prune_operations_with_nils!(parent.r,parent)
      elsif node.r == nil
        parent.l = node.l
        node = nil
        prune_operations_with_nils!(parent.l,parent)
        prune_operations_with_nils!(parent.r,parent)
      else
        prune_operations_with_nils!(node.l,node)
        prune_operations_with_nils!(node.r,node)
      end
    end
    def calculate_coefficient(path_to_variable)
      immediate_operation = path_to_variable[1]
      variable            = path_to_variable.first
      if not (immediate_operation.sym =~ MULTIPLICATION) and not (immediate_operation.sym =~ DIVISION)
        if immediate_operation.sym =~ SUBTRACTION and immediate_operation.r == variable
          -1.0
        else
          1.0
        end
      else
        immediate_operation.r == variable ? immediate_operation.l.sym.to_f : immediate_operation.r.sym.to_f
      end
    end
    def path(r,node=@root)
      @p.path!(r,node)
    end
    private :fixr!,:isolate,:eval
  end
end

s = T2Solver::Solver.new('x=2x')
puts s.to_s(:infix)
#s.solve!
s.combine_like_terms!
puts s.to_s(:infix)
puts s.work

#s = T2Solver::Solver.new('2(x-1)=-x+4')
#s.solve!
#puts s.work