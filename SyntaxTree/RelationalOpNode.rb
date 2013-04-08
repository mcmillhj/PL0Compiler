class RelationalOpNode < Node
  def initialize(op, l = nil, r = nil)
    @op    = op
    @left  = l 
    @right = r
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    @left.accept(visitor, traversal)  if @left
    @right.accept(visitor, traversal) if @right
     
    visitor.visit_relop_node self
  end
  
  def to_s
    return "RelopNode -> #{@left} #{@op} #{@right}"
  end
end