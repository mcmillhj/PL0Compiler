class IfStatementNode < StatementNode
  attr_reader :expr_node, :statement_node, :if_statement_a_node
  
  def initialize(expr_node, statement_node, if_statement_a)
    @expr_node           = expr_node
    @statement_node      = statement_node
    @if_statement_a_node = if_statement_a
  end
  
  def accept visitor   
    @expr_node.accept visitor           if @expr_node
    @statement_node.accept visitor      if @statement_node
    @if_statement_a_node.accept visitor if @if_statement_a_node
    
    visitor.visit_if_statement_node self
  end
  
  def to_s
    return "IfStatementNode -> if #{@expr_node} then #{@statement_node} #{@if_statement_a_node}"
  end
end