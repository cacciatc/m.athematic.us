require File.dirname(__FILE__) + '/node'

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