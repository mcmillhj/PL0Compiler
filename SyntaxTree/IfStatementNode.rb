class IfStatementNode < StatementNode
  def initialize(cond_node, expr_node)
    @condition_node  = cond_node
    @expression_node = expr_node
  end
  
  # todo
  def accept(visitor)
    
  end
end