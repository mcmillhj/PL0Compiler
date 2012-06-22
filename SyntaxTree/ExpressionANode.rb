require_relative 'Node.rb'
class ExpressionANode < Node
  def initialize(add_sub_node, term_node, expr_a_node)
    @add_sub_node      = add_sub_node
    @term_node         = term_node 
    @expression_a_node = expr_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def collect
    return {"ExpressionANode" => [@add_sub_node.collect, @term_node.collect, @expression_a_node.collect]} if @add_sub_node and @term_node and @expression_a_node
    return {"ExpressionANode" => nil}
  end
  
  def to_s
    return "ExpressionANode -> #{@add_sub_node.to_s} #{@term_node.to_s} #{@expression_a_node.to_s}" if @add_sub_node and @term_node and @expression_a_node
    return "ExpressionANode -> e"
  end
end