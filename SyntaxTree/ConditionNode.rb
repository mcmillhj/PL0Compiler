require_relative 'Node.rb'
class ConditionNode < Node
  def initialize(expr_node_1, relop, expr_node_2)
    @expression_node_1 = expr_node_1
    @relop_node        = relop
    @expression_node_2 = expr_node_2
  end
  
  # todo
  def accept(visitor)
    
  end
end