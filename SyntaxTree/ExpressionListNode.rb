class ExpressionListNode < Node
  def initialize(expr, expr_list)
    @expr      = expr
    @expr_list = expr_list 
  end  
  
  def accept(visitor, traversal = :pre)
    visitor.visit_expression_list_node self if traversal == :pre
    
    @expr.accept(visitor, traversal)      if @expr
    @expr_list.accept(visitor, traversal) if @expr_list
    
    visitor.visit_expression_list_node self if traversal == :post
  end
  
  def to_s
    "ExpressionListNode -> [#{@expr}, #{@expr_list}]"
  end
end
