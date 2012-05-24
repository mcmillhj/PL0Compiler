class WhileStatementNode < StatementNode
  @condition_node = nil
  @statement_node = nil
  
  def initialize(cond_node, state_node)
    @condition_node = cond_node
    @statement_node = state_node
  end
  
  # todo
  def accept(visitor)
    
  end
end