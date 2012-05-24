class BeginStatementNode < StatementNode
  @statement_list_node = nil
  
  def initialize(slist_node)
    @statement_list_node = slist_node
  end
  
  # todo
  def accept(visitor)
    
  end
end