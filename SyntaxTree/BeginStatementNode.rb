require_relative 'StatementNode.rb'
class BeginStatementNode < StatementNode
  def initialize(slist_node)
    @statement_list_node = slist_node
  end
  
  def accept(visitor, traversal = :pre)
    visitor.visit_begin_statement_node self if traversal == :pre
    
    @statement_list_node.accept(visitor, traversal) if @statement_list_node
    
    visitor.visit_begin_statement_node self if traversal == :post
  end
  
  def to_s
    return "BeginStatementNode -> begin #{@statement_list_node.to_s} end"  if @statement_list_node
    return "BeginStatementNode -> e"
  end
end