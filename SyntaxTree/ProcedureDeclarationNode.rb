require_relative 'Node.rb'
class ProcedureDeclarationNode < Node
  def initialize(proc_a_node)
    @proc_a_node = proc_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def collect
    return {"ProcedureDeclarationNode" => @proc_a_node.collect} if @proc_a_node
    return {"ProcedureDeclarationNode" => nil}
  end
  
  def to_s
    return "ProcedureDeclarationNode -> #{@proc_a_node.to_s}" if @proc_a_node
    return "ProcedureDeclarationNode -> e"
  end
end