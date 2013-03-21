require_relative 'StatementNode.rb'
class PrintStatementNode < StatementNode
  def initialize(expr_list_node)
    @expr_l_node = expr_list_node
  end
  
  # todo
  def accept(visitor)

  end
  
  def collect
    return {"PrintStatementNode" => @id}
  end
  
  def to_s
    return "PrintStatementNode -> print #{@expr_l_node}"
  end
end