class TermNode < Node
  @factor_node = nil
  @term_a_node = nil
  
  def initialize(fact_node, term_a_node)
    @factor_node = fact_node
    @term_a_node = term_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
end