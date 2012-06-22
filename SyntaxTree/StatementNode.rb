require_relative 'Node.rb'
class StatementNode < Node
  # A StatementNode can represent any subclass of StatementNode
  #
  # PrintStatementNode, AssignmentStatementNode, CallStatementNode
  # BeginStatementNode, IfStatementNode, WhileStatementNode, and
  # ReadStatementNodee
  def initialize(statement_node)
    @statement_node = statement_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def collect
    return {"StatementNode" => [@statement_node.collect]} if @statement_node
    return {"StatementNode" => nil}
  end
  
  def to_s
    return "StatementNode -> #{@statement_node.to_s}" if @statement_node
    return "StatementNode -> e"
  end
end