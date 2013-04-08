class IfStatementANode < StatementNode
  def initialize(statement_node)
    @statement_node = statement_node
  end
  
  def accept(visitor, traversal = :pre)
    visitor.visit_if_statement_a_node self if traversal == :pre
    
    @statement_node.accept(visitor, traversal) if @statement_node
    
    visitor.visit_if_statement_a_node self if traversal == :post
  end
  
  def to_s
    return "IfStatementANode -> else #{@statement_node.to_s}"
  end
end