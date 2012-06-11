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
end