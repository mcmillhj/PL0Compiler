require_relative 'StatementNode.rb'
class ReturnStatementNode < StatementNode
  def initialize(expr)
    @expr_node = expr
  end
  
  def accept(visitor)
    @expr_node.accept(visitor)
    visitor.visit_return_statement_node(self)
  end
  
  def collect
    return {"ReturnStatementNode" => ['return', @expr_node.collect]}
  end
  
  def to_s
    return "ReturnStatementNode -> #{@expr_node}"
  end
end