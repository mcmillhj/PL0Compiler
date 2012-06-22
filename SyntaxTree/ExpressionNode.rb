require_relative 'Node.rb'
class ExpressionNode < Node
  def initialize(term_node, expr_a_node)
    @term_node         = term_node
    @expression_a_node = expr_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def collect
    return {"ExpressionNode" => [@term_node.collect, @expression_a_node.collect]} if @expression_a_node
    return {"ExpressionNode" => @term_node.collect}  
  end
  
  def to_s
    return "ExpressionNode -> #{@term_node.to_s} #{@expression_a_node.to_s}" if @expression_a_node
    return "ExpressionNode -> #{@term_node.to_s}"
  end
end