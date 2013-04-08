class IfStatementNode < StatementNode
  def initialize(expr_node, statement_node, if_statement_a)
    @expr_node           = expr_node
    @statement_node      = statement_node
    @if_statement_a_node = if_statement_a
  end
  
  def accept(visitor, traversal = :pre)
    visitor.visit_if_statement_node self if traversal == :pre
    
    @expr_node.accept(visitor, traversal)           if @expr_node
    @statement_node.accept(visitor, traversal)      if @statement_node
    @if_statement_a_node.accept(visitor, traversal) if @if_statement_a_node
    
    visitor.visit_if_statement_node self if traversal == :post
  end
  
  def to_s
    return "IfStatementNode -> if #{@expr_node} then #{@statement_node} #{@if_statement_a_node}"
  end
end