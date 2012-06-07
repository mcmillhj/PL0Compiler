require_relative 'Node.rb'
class TermANode < Node
  def initialize(mult_div_node, factor_node, term_a_node)
    @mult_div_node = mult_div_node
    @factor_node   = factor_node
    @term_a_node   = term_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
end