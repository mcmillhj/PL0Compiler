class ConditionNode < Node
  def initialize(expr_node_1, relop, expr_node_2)
    @expression_node_1 = expr_node_1
    @relop_node        = relop
    @expression_node_2 = expr_node_2
  end
  
  # todo
  def accept(visitor)

  end
  
  def collect
    return {"ConditionNode" => [@expression_node_1.collect, @relop_node.collect, @expression_node_2.collect]} if @relop_node and @expression_node_2
    return {"ConditionNode" => ["odd", @expression_node_1.collect]}
  end
  
  def to_s
    return "ConditionNode -> #{@expression_node_1.to_s} #{@relop_node.to_s} #{@expression_node_2.to_s}" if @relop_node and @expression_node_2
    return "ConditionNode -> odd #{@expression_node_1.to_s}"
  end
end