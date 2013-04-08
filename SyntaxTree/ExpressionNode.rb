class ExpressionNode < Node
  def initialize(rel_expr)
    @rel_expression = rel_expr
  end
  
  def accept(visitor, traversal = :pre)
    visitor.visit_expression_node self if traversal == :pre
    
    @rel_expression.accept(visitor, traversal) if @rel_expression
    
    visitor.visit_expression_node self if traversal == :post
  end
  
  def to_s
    return "ExpressionNode -> #{@rel_expression}"
  end
end