class ProcANode < Node
  def initialize(id, block_node, proc_a_node)
    @id          = id
    @block_node  = block_node
    @proc_a_node = proc_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
end