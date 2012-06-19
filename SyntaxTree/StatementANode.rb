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
    return "StatementANode -> ; #{@statement_node.to_s} #{@statement_a_node.to_s}" unless @statement_a_node.nil?
    return "StatementANode -> ; #{@statement_node.to_s}" unless @statement_node.nil?
    return "StatementANode -> e"
  end
end