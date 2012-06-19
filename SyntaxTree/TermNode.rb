require_relative 'Node.rb'
class TermNode < Node
  def initialize(fact_node, term_a_node)
    @factor_node = fact_node
    @term_a_node = term_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def to_s
    return "TermNode -> #{@factor_node.to_s} #{@term_a_node.to_s}" unless @term_a_node.nil?
    return "TermNode -> #{@factor_node.to_s}"
  end
end