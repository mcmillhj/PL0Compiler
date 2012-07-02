require_relative 'StatementNode.rb'
class ReadStatementNode < StatementNode
  def initialize(id)
    @id = id
  end
  
  # todo
  def accept(visitor)
    #TODO find something to do with @id 
    visitor.visit_read_statement_node(self)  
  end
  
  def collect
    return {"ReadStatementNode" => @id}
  end
  
  def to_s
    return "ReadStatementNode -> read #{@id}"
  end
end