class BlockNode < Node
  @declaration_node = nil
  @statement_node   = nil
  
  def initialize(decl_node, statement_node)
    @declaration_node = decl_node
    @statement_node   = statement_node
  end
  
  # todo
  def accept(visitor)
    
  end
end