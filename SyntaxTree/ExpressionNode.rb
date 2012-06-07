class ExpressionNode < Node
  def initialize(term_node, expr_a_node)
    @term_node         = term_node
    @expression_a_node = expr_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
end