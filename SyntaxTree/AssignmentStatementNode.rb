require_relative 'StatementNode.rb'
class AssignmentStatementNode < StatementNode
  def initialize(idlist_node, expr_list_node)
    @idlist_node    = idlist_node
    @expr_list_node = expr_list_node
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def collect
    return {"AssignmentStatementNode" => [@idlist_node.collect, ":=", @expr_list_node.collect]}
  end
  
  def to_s
    return "AssignmentStatementNode -> #{@idlist_node} := #{@expr_list_node}"
  end
end