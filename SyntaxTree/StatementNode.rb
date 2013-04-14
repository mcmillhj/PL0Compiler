require_relative 'Node.rb'
class StatementNode < Node
  attr_reader :statement_node
  
  # A StatementNode can represent any subclass of StatementNode
  #
  # PrintStatementNode, AssignmentStatementNode, CallStatementNode
  # BeginStatementNode, IfStatementNode, WhileStatementNode, and
  # ReadStatementNode
  def initialize statement_node
    super()
    @statement_node = statement_node
  end
  
  # todo
  def accept visitor
    @statement_node.accept visitor if @statement_node
    visitor.visit_statement_node self 
  end
  
  def to_s
    return "StatementNode -> #{@statement_node}" if @statement_node
    return "StatementNode -> e"
  end
end