require_relative 'Node.rb'
class ProcANode < Node
  def initialize(id, block_node, proc_a_node)
    @id          = id
    @block_node  = block_node
    @proc_a_node = proc_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def to_s
    return "ProcANode -> #{@id}\t#{@block_node.to_s}\t#{@proc_a_node.to_s}\n"
  end
end