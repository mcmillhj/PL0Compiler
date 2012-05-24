class AssignmentStatementNode < StatementNode
  @id              = nil
  @expression_node = nil
  
  def initialize(id, expr_node)
    @id              = id
    @expression_node = expr_node
  end
  
  # todo
  def accept(visitor)
    
  end
end