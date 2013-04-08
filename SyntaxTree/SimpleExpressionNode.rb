class SimpleExpressionNode < Node
  def initialize(add_sub_op)
    @add_sub_node = add_sub_op
  end
  
  def accept(visitor, traversal = :pre)
    @add_sub_node.accept(visitor, traversal)
    visitor.visit_simple_expr_node self
  end
  
  def to_s
    return "SimpleExpression -> #{@add_sub_node}"
  end
end