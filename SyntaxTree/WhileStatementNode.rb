require_relative 'StatementNode.rb'
class WhileStatementNode < StatementNode
  def initialize(expr, state_node)
    @expr           = expr
    @statement_node = state_node
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    @expr.accept(visitor, traversal)           if @expr
    @statement_node.accept(visitor, traversal) if @statement_node
    
    visitor.visit_while_statement_node self 
  end
  
  def to_s
    return "WhileStatementNode -> while #{@expr} do #{@statement_node}"
  end
end