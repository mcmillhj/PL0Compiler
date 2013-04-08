class MultDivOpNode < Node
  attr_reader :op, :left, :right
  def initialize(op, left = nil, right = nil)
    @op    = op 
    @left  = left
    @right = right
  end
  
  # todo
  def accept(visitor, traversal = :pre)    
    @left.accept(visitor, traversal)  if @left
    @right.accept(visitor, traversal) if @right
    
    visitor.visit_mult_div_op_node self
  end
  
  def to_s
    return "MultDivOpNode -> #{@left} #{@op} #{@right}"
  end
end