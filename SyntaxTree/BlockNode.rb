class BlockNode < Node
  def initialize(decl_node, statement_node)
    @declaration_node = decl_node
    @statement_node   = statement_node
  end
  
  # todo
  def accept(visitor)
    
  end
end