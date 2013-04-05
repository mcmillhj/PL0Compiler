class ExpressionNode < Node
  def initialize(rel_expr)
    @rel_expresion = rel_expr
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "ExpressionNode -> #{@rel_expresion}"
  end
end