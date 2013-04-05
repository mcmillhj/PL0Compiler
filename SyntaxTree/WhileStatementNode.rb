require_relative 'StatementNode.rb'
class WhileStatementNode < StatementNode
  def initialize(bool_expr, state_node)
    @bool_expr = bool_expr
    @statement_node = state_node
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "WhileStatementNode -> while #{@bool_expr} do #{@statement_node}" if @statement_node
    return "WhileStatementNode -> while #{@bool_expr} do"
  end
end