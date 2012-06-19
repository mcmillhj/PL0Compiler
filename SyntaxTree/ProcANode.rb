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
    return "ProcANode -> procedure #{@id} ; #{@block_node.to_s} ; #{@proc_a_node.to_s}" unless @proc_a_node.nil?
    return "ProcANode -> procedure #{@id} ; #{@block_node.to_s} ;" unless @id.nil? and @block_node.nil?
    return "ProcANode -> e"
  end
end