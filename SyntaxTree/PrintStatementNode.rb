require_relative 'StatementNode.rb'
class PrintStatementNode < StatementNode
  def initialize(id)
    @id = id
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def to_s
    return "PrintStatementNode -> #{@id}"
  end
end