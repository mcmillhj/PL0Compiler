require_relative 'StatementNode.rb'
class ReadStatementNode < StatementNode
  def initialize(id)
    @id = id
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def collect
    return {"ReadStatementNode" => @id}
  end
  
  def to_s
    return "ReadStatementNode -> read #{@id}"
  end
end