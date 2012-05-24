class IfStatementNode < StatementNode
  @condition_node  = nil
  @expression_node = nil
  def initialize(cond_node, expr_node)
    @condition_node  = cond_node
    @expression_node = expr_node
  end
  
  # todo
  def accept(visitor)
    
  end
end