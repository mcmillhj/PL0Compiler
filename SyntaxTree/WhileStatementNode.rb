require_relative 'StatementNode.rb'
class WhileStatementNode < StatementNode
  def initialize(cond_node, state_node)
    @condition_node = cond_node
    @statement_node = state_node
  end
  
  # todo
  def accept(visitor)
    @condition_node.accept(visitor)
    @statement_node.accept(visitor) if @statement_node
    visitor.visit_while_statement_node(self) 
  end
  
  def collect
    return {"WhileStatementNode" => ["while", @condition_node.collect, @statement_node.collect]} if @statement_node
    return {"WhileStatementNode" => ["while", @condition_node.collect]}
  end
  
  def to_s
    return "WhileStatementNode -> while #{@condition_node.to_s} do #{@statement_node.to_s}" if @statement_node
    return "WhileStatementNode -> while #{@condition_node.to_s} do"
  end
end