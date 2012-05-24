class ReadStatementNode < StatementNode
  @id = nil
  
  def initialize(id)
    @id = id
  end
  
  # todo
  def accept(visitor)
    
  end
end