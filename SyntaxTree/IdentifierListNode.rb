class IdentifierListNode < Node
  def initialize(id, ident_list)
    @id         = id
    @ident_list = ident_list
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "IdentifierListNode -> [#{@id}, #{@ident_list}]"
  end
end