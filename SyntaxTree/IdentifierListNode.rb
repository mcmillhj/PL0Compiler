class IdentifierListNode < Node
  @id           = nil
  @ident_a_node = nil
  
  def initialize(id, ident_a_node)
    @id           = id
    @ident_a_node = ident_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
end