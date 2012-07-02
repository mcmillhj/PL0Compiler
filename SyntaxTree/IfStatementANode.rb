require_relative 'IfStatementNode.rb'

class IfStatementANode < IfStatementNode
  def initialize(statement_node)
    @statement_node = statement_node
  end
  
  # TODO implement accept
  def accept(visitor)
    @statement_node.accept(visitor) if @statement_node
    visitor.visit_if_statement_a_node(self)  
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