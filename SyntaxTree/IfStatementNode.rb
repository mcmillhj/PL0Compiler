require_relative 'StatementNode.rb'
class IfStatementNode < StatementNode
  def initialize(cond_node, statement_node)
    @condition_node  = cond_node
    @statement_node = statement_node
  end
  
  # TODO implement accept
  def accept(visitor)
    
  end
end