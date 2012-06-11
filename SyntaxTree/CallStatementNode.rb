require_relative 'Node.rb'
class CallStatementNode < StatementNode
  # id Name of the procedure to be called
  def initialize(id)
    @id = id
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def to_s
    return "CallStatementNode -> #{@id}\n"
  end
end