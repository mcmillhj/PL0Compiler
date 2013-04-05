class BooleanExpressionNode < Node
  def initialize(bool_and_or)
    @bool_expr = bool_and_or
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "BooleanExpressionNode -> #{@bool_expr}"
  end
end