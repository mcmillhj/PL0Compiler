class IfStatementNode < StatementNode
  def initialize(bool_node, statement_node, if_statement_a)
    @bool_node           = bool_node
    @statement_node      = statement_node
    @if_statement_a_node = if_statement_a
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "IfStatementNode -> if #{@bool_node.to_s} then #{@statement_node.to_s} #{@if_statement_a_node.to_s}"
  end
end