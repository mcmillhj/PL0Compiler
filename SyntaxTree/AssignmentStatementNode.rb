class AssignmentStatementNode < StatementNode
  def initialize(id, expr_node)
    @id              = id
    @expression_node = expr_node
  end
  
  # todo
  def accept(visitor)
    
  end
end