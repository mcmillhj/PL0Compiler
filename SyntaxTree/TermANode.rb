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
  
  def to_s
    return "TermANode -> #{@mult_div_node.to_s} #{@factor_node.to_s} #{@term_a_node.to_s}" unless @mult_div_node.nil? and @factor_node.nil? and @term_a_node.nil?
    return "TermANode -> #{@mult_div_node.to_s} #{@factor_node.to_s}" unless @mult_div_node.nil? and @factor_node.nil?
    return "TermANode -> e"
  end
end