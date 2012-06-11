require_relative 'IfStatementNode.rb'

class IfStatmentANode < IfStatementNode
  def initialize(statement_node)
    @statement_node = statement_node
  end
  
  # TODO implement accept
  def accept(visitor)
    
  end
end