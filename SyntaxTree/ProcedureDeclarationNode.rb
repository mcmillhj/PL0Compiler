class ProcedureDeclarationNode < Node
  @proc_a_node = nil
  
  def initialize(proc_a_node)
    @proc_a_node = proc_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
end