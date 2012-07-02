require_relative 'Node.rb'
class TermANode < Node
  def initialize(mult_div_node, factor_node, term_a_node)
    @mult_div_node = mult_div_node
    @factor_node   = factor_node
    @term_a_node   = term_a_node
  end
  
  # todo
  def accept(visitor)
    @mult_div_node.accept(visitor)
    @factor_node.accept(visitor)
    @term_a_node.accept(visitor)   if @term_a_node
    visitor.visit_term_a_node(self)  
  end
  
  def collect
    return {"TermANode" => [@mult_div_node.collect, @factor_node.collect, @term_a_node.collect]} if @mult_div_node and @factor_node and @term_a_node
    return {"TermANode" => Array[@mult_div_node.collect, @factor_node.collect]}                  if @mult_div_node and @factor_node
    return {"TermANode" => nil} 
  end
  
  def to_s
    return "TermANode -> #{@mult_div_node.to_s} #{@factor_node.to_s} #{@term_a_node.to_s}" if @mult_div_node and @factor_node and @term_a_node
    return "TermANode -> #{@mult_div_node.to_s} #{@factor_node.to_s}"                      if @mult_div_node and @factor_node
    return "TermANode -> e"
  end
end