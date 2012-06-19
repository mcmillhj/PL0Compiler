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
  
  def to_s
    return "StatementNode -> #{@statement_node.to_s}" unless @statement_node.nil?
    return "StatementNode -> e"
  end
end