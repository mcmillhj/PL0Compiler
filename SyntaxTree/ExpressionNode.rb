class ExpressionNode < Node
  @term_node         = nil
  @expression_a_node = nil
  
  def initialize(term_node, expr_a_node)
    @term_node         = term_node
    @expression_a_node = expr_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
end