require_relative 'Node.rb'
class FuncANode < Node
  def initialize(id, block_node, func_a_node)
    @id          = id
    @block_node  = block_node
    @func_a_node = func_a_node
  end
  
  # todo
  def accept(visitor)
    #TODO do something with @id
    @block_node.accept(visitor)  if @block_node
    @proc_a_node.accept(visitor) if @func_a_node
    visitor.visit_procedure_a_node(self) 
  end
  
  def collect
    return {"FuncANode" => Array[@id, @block_node.collect, @func_a_node.collect]} if @func_a_node
    return {"FuncANode" => Array[@id, @block_node.collect]}                       if @block_node and @id
    return {"FuncANode" => nil}
  end
  
  def to_s
    return "ProcANode -> procedure #{@id} ; #{@block_node.to_s} ; #{@proc_a_node.to_s}" if @proc_a_node
    return "ProcANode -> procedure #{@id} ; #{@block_node.to_s} ;"                      if @block_node and @id
    return "ProcANode -> e"
  end
end