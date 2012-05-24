class AddSubOpNode < Node
  @op = nil
  
  # either a plus or a minus
  def initialize(op)
    @op = op 
  end
  
  # todo
  def accept(visitor)
    
  end
end