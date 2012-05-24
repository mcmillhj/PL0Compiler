class TermANode < Node
  @mult_div_node     = nil
  @term_node         = nil
  @expression_a_node = nil
  
  def initialize(mult_div_node, term_node, expr_a_node)
    @mult_div_node     = mult_div_node
    @term_node         = term_node
    @expression_a_node = expr_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
end