class ExpressionNode < Node
  attr_reader :expression
  
  def initialize expr
    @expression = expr
  end
  
  def accept visitor
    @expression.accept visitor if @expression
    
    visitor.visit_expression_node self
  end
  
  def get_type
    @expression.type
  end
  
  def to_s
    return "#{@expression}"
  end
end