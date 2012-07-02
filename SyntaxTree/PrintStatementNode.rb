require_relative 'StatementNode.rb'
class PrintStatementNode < StatementNode
  def initialize(id)
    @id = id
  end
  
  # todo
  def accept(visitor)
    #TODO find something to do with @id
    visitor.visit_print_statement_node(self) 
  end
  
  def collect
    return {"PrintStatementNode" => @id}
  end
  
  def to_s
    return "PrintStatementNode -> print #{@id}"
  end
end