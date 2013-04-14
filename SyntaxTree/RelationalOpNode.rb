class RelationalOpNode < Node
  def initialize(op, l = nil, r = nil)
    super()
    @op    = op
    @left  = l 
    @right = r
  end
  
  # todo
  def accept visitor
    @left.accept  visitor if @left
    @right.accept visitor if @right
     
    visitor.visit_relop_node self
  end
  
  def to_s
    return "#{@left} #{@op} #{@right}"
  end
end