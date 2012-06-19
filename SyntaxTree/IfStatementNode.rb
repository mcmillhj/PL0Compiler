require_relative 'StatementNode.rb'

class IfStatementNode < StatementNode
  def initialize(cond_node, statement_node, if_statement_a)
    @condition_node      = cond_node
    @statement_node      = statement_node
    @if_statement_a_node = if_statement_a
  end
  
  # TODO implement accept
  def accept(visitor)
    
  end
  
  def to_s
    return "IfStatementNode -> if #{@condition_node.to_s} then #{@statement_node.to_s} #{@if_statement_a_node.to_s}" unless @if_statement_a_node.nil?
    return "IfStatementNode -> if #{@condition_node.to_s} then #{@statement_node.to_s}"
  end
end