require_relative 'StatementNode.rb'

class WhileStatementNode < StatementNode
  attr_reader :expr, :statement_node
  
  def initialize(expr, state_node)
    @expr           = expr
    @statement_node = state_node
  end
  
  # todo
  def accept visitor
    @expr.accept visitor           if @expr
    @statement_node.accept visitor if @statement_node
    
    visitor.visit_while_statement_node self 
  end
  
  def to_s
    return "WhileStatementNode -> while #{@expr} do #{@statement_node}"
  end
end