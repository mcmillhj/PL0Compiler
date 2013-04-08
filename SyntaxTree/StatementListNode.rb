class StatementListNode < Node
  def initialize(state_node, state_list)
    @statement_node = state_node
    @state_list     = state_list
  end
  
  def accept(visitor, traversal = :pre)
    @statement_node.accept(visitor, traversal) if @statement_node
    @state_list.accept(visitor, traversal)     if @state_list
    visitor.visit_statement_list_node self
  end
  
  def to_s
    return "StatementListNode -> #{@statement_node} #{@statement_a_node}" if @statement_node and @state_list
    return "StatementListNode -> #{@statement_node}"                      if @state_list
    return "StatementListNode -> e"
  end
end