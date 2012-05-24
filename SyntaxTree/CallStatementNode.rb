class CallStatementNode < StatementNode
  @id = nil #name of procedure to be called
  
  def initialize(id)
    @id = id
  end
  
  # todo
  def accept(visitor)
    
  end
end