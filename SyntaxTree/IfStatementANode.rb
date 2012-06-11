require_relative 'IfStatementNode.rb'

class IfStatmentANode < IfStatementNode
  def initialize(statement_node)
    @statement_node = statement_node
  end
  
  # TODO implement accept
  def accept(visitor)
    
  end
  
  def to_s
    return "IfStatementANode -> #{@statement_node.to_s}"
  end
end