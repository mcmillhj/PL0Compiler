require_relative 'StatementNode.rb'
class ReadStatementNode < StatementNode
  def initialize(id)
    @id = id
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    visitor.visit_read_statement_node self
  end
  
  def to_s
    return "ReadStatementNode -> read #{@id}"
  end
end