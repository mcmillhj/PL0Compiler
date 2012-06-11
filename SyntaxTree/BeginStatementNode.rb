require_relative 'StatementNode.rb'
class BeginStatementNode < StatementNode
  def initialize(slist_node)
    @statement_list_node = slist_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def to_s
    return "BeginStatementNode -> #{@statement_list_node.to_s}"
  end
end