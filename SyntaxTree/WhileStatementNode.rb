require_relative 'StatementNode.rb'
class WhileStatementNode < StatementNode
  def initialize(cond_node, state_node)
    @condition_node = cond_node
    @statement_node = state_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def to_s
    return "WhileStatementNode -> #{@condition_node.to_s}\t#{@statement_node.to_s}\n"
  end
end