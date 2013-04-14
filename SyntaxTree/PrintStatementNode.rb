require_relative 'StatementNode.rb'

class PrintStatementNode < StatementNode
  def initialize expr_list_node
    super self
    @expr_l_node = expr_list_node
  end

  # todo
  def accept visitor    
    @expr_l_node.accept visitor if @expr_l_node
    
    visitor.visit_print_statement_node self
  end

  def to_s
    return "PrintStatementNode -> print #{@expr_l_node}"
  end
end