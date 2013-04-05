class SimpleExpressionNode < Node
  def initialize(add_sub_op)
    @add_sub_node = add_sub_op
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "SimpleExpression -> #{@add_sub_node}"
  end
end