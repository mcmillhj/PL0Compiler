require_relative 'StatementNode.rb'
class ReturnStatementNode < StatementNode
  attr_reader :expr_node
  
  def initialize expr
    super()
    @expr_node = expr
  end
  
  # todo
  def accept visitor
    @expr_node.accept visitor if @expr_node
    visitor.visit_return_statement_node self
  end
  
  def to_s
    return "ReturnStatementNode -> #{@expr_node}"
  end
end