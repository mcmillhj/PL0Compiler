require_relative 'IfStatementNode.rb'

class IfStatmentANode < IfStatementNode
  def initialize(statement_node)
    @statement_node = statement_node
  end
  
  # TODO implement accept
  def accept(visitor)
    
  end
  
  def collect
    return {"IfStatementANode" => ["else", @statement_node.collect]} if @statement_node
    return {"IfStatementANode" => nil}
  end
  
  def to_s
    return "IfStatementANode -> else #{@statement_node.to_s}" if @statement_node
    return "IfStatementANode -> e"
  end
end