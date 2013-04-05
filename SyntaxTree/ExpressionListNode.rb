class ExpressionListNode < Node
  def initialize(expr, expr_list)
    @expr      = expr
    @expr_list = expr_list 
  end  
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    "ExpressionListNode -> [#{@expr}, #{@expr_list}]"
  end
end
