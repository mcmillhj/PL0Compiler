require_relative 'StatementNode.rb'
class ReadStatementNode < StatementNode
  def initialize(id)
    @id = id
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def to_s
    return "ReadStatementNode -> #{@id}"
  end
end