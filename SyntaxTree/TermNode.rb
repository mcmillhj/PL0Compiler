require_relative 'Node.rb'
class TermNode < Node
  def initialize(fact_node, term_a_node)
    @factor_node = fact_node
    @term_a_node = term_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def collect
    return {"TermNode" => [@factor_node.collect, @term_a_node.collect]} if @term_a_node
    return {"TermNode" => @factor_node.collect}
  end
  
  def to_s
    return "TermNode -> #{@factor_node.to_s} #{@term_a_node.to_s}" if @term_a_node
    return "TermNode -> #{@factor_node.to_s}"
  end
end