require_relative 'StatementNode.rb'

class PrintStatementNode < StatementNode
  def initialize(expr_list_node)
    @expr_l_node = expr_list_node
  end

  # todo
  def accept(visitor, traversal = :pre)
    visitor.visit_print_statement_node self if traversal == :pre
    
    @expr_l_node.accept(visitor, traversal) if @expr_l_node
    
    visitor.visit_print_statement_node self if traversal == :post
  end

  def collect
    return {"PrintStatementNode" => @expr_l_node}
  end

  def to_s
    return "PrintStatementNode -> print #{@expr_l_node}"
  end
end