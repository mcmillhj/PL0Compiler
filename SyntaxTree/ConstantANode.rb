class ConstantANode < Node
  @id    = nil
  @value = nil
  @const_a_node = nil
  
  def initialize(id, valu)
    @id           = id
    @value        = value
    @const_a_node = const_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
end