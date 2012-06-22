require_relative 'StatementNode.rb'
class PrintStatementNode < StatementNode
  def initialize(id)
    @id = id
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def collect
    return {"PrintStatementNode" => @id}
  end
  
  def to_s
    return "PrintStatementNode -> print #{@id}"
  end
end