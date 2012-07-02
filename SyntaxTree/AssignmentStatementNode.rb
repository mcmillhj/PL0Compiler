require_relative 'StatementNode.rb'
class AssignmentStatementNode < StatementNode
  def initialize(id, expr_node)
    @id              = id
    @expression_node = expr_node
  end
  
  # todo
  def accept(visitor)
    #TODO do something with @id
    @expression_node.accept(visitor)
    visitor.visit_assign_statement_node(self)
  end
  
  def collect
    return {"AssignmentStatementNode" => [@id, ":=", @expression_node.collect]}
  end
  
  def to_s
    return "AssignmentStatementNode -> #{@id} := #{@expression_node.to_s}"
  end
end