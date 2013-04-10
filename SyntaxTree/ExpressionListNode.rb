class ExpressionListNode < Node
  def initialize(expr_list)
    @expr_list = expr_list 
  end  
  
  def accept visitor  
    # visit all expressions 
    @expr_list.each do |expr|
      expr.accept visitor
    end 
    
    visitor.visit_expression_list_node self
  end
  
  def types
    @expr_list.map{|e| e.get_type}
  end
  
  def to_s
    "ExpressionListNode -> #{@expr_list}"
  end
end
