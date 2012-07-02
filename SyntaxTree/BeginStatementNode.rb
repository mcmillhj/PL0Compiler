require_relative 'StatementNode.rb'
class BeginStatementNode < StatementNode
  def initialize(slist_node)
    @statement_list_node = slist_node
  end
  
  # todo
  def accept(visitor)
    @statement_list_node.accept(visitor)
    visitor.visit_begin_statement_node(self)  
  end
  
  def collect
    return {"BeginStatementNode" => ["begin", @statement_list_node.collect, "end"]} if @statement_list_node
    return {"BeginStatementNode" => nil}
  end
  
  def to_s
    return "BeginStatementNode -> begin #{@statement_list_node.to_s} end"  if @statement_list_node
    return "BeginStatementNode -> e"
  end
end