class ExpressionListNode < Node
  attr_reader :expr_list
  
  def initialize expr_list
    super()
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
    "#{@expr_list.join(",")}"
  end
end
