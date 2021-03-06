require_relative 'StatementNode.rb'

class ReadStatementNode < StatementNode
  def initialize id
    super self
    @id = id
  end
  
  # todo
  def accept visitor
    visitor.visit_read_statement_node self
  end
  
  def to_s
    return "ReadStatementNode -> read #{@id}"
  end
end