class ProgramNode < Node
  @block_node = nil
  def initialize(block_node)
    @block_node = block_node
  end
  
  # todo
  def accept(visitor)
    
  end
end