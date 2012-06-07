require_relative 'Node.rb'
class TermNode < Node
  def initialize(fact_node, term_a_node)
    @factor_node = fact_node
    @term_a_node = term_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
end