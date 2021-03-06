class MultDivOpNode < Node
  attr_reader :op, :left, :right
  
  def initialize(op, left = nil, right = nil)
    super()
    @op    = op 
    @left  = left
    @right = right
  end
  
  # todo
  def accept visitor 
    @left.accept visitor  if @left
    @right.accept visitor if @right
    
    visitor.visit_mult_div_op_node self
  end
  
  def to_s
    return "MultDivOp -> #{@left} #{@op} #{@right}"
  end
end