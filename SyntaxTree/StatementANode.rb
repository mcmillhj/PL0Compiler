class StatementANode < Node
  def initialize(state_node, state_a_node)
    @statment_node    = state_node
    @statement_a_node = state_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
end