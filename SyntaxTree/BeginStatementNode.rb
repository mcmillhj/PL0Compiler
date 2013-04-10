require_relative 'StatementNode.rb'
class BeginStatementNode < StatementNode
  attr_reader :statement_list_node
  
  def initialize(slist_node)
    @statement_list_node = slist_node
  end
  
  def accept visitor    
    @statement_list_node.accept visitor if @statement_list_node
    
    visitor.visit_begin_statement_node self
  end
  
  def to_s
    return "BeginStatementNode -> begin #{@statement_list_node.to_s} end"  if @statement_list_node
    return "BeginStatementNode -> e"
  end
end