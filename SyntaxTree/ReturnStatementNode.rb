require_relative 'StatementNode.rb'
class ReturnStatementNode < StatementNode
  def initialize(expr)
    @expr_node = expr
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    @expr_node.accept(visitor, traversal)
    visitor.visit_expression_node self
  end
  
  def to_s
    return "ReturnStatementNode -> #{@expr_node}"
  end
end