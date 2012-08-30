require_relative 'StatementNode.rb'
class AssignmentStatementNode < StatementNode
  def initialize(idlist_node, expr_list_node)
    @idlist_node    = idlist_node
    @expr_list_node = expr_list_node
  end
  
  # todo
  def accept(visitor)
    @idlist_node.accept(visitor)
    @expr_list_node.accept(visitor)
    visitor.visit_assign_statement_node(self)
  end
  
  def collect
    return {"AssignmentStatementNode" => [@idlist_node.collect, ":=", @expr_list_node.collect]}
  end
  
  def to_s
    return "AssignmentStatementNode -> #{@id} := #{@expression_node.to_s}"
  end
end