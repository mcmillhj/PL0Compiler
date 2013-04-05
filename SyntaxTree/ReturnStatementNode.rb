require_relative 'StatementNode.rb'
class ReturnStatementNode < StatementNode
  def initialize(expr)
    @expr_node = expr
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "ReturnStatementNode -> #{@expr_node}"
  end
end