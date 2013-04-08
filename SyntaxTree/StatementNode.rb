require_relative 'Node.rb'
class StatementNode < Node
  # A StatementNode can represent any subclass of StatementNode
  #
  # PrintStatementNode, AssignmentStatementNode, CallStatementNode
  # BeginStatementNode, IfStatementNode, WhileStatementNode, and
  # ReadStatementNode
  def initialize(statement_node)
    @statement_node = statement_node
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    @statement_node.accept(visitor, traversal) if @statement_node
    visitor.visit_statement_node self 
  end
  
  def to_s
    return "StatementNode -> #{@statement_node}" if @statement_node
    return "StatementNode -> e"
  end
end