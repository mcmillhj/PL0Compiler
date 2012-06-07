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
end