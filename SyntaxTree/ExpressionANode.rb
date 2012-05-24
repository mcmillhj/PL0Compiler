class ExpressionANode < Node
  @add_sub_node      = nil
  @term_node         = nil
  @expression_a_node = nil
  
  def initialize(add_sub_node, term_node, expr_a_node)
    @add_sub_node      = add_sub_node
    @term_node         = term_node 
    @expression_a_node = expr_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
end