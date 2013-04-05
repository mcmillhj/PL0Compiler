class IfStatementANode < StatementNode
  def initialize(statement_node)
    @statement_node = statement_node
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "IfStatementANode -> else #{@statement_node.to_s}"
  end
end