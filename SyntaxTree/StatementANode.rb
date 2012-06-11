require_relative 'Node.rb'
class StatementANode < Node
  def initialize(state_node, state_a_node)
    @statement_node    = state_node
    @statement_a_node = state_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def to_s
    return "StatementANode -> #{@statement_node.to_s}\t#{@statement_a_node}\n"
  end
end