class IdentifierListNode < Node
  attr_reader :id, :id_list
  def initialize(id, ident_list)
    @id      = id
    @id_list = ident_list
  end
  
  def accept(visitor, traversal = :pre)
    visitor.visit_identifier_list_node self
    
    @id_list.accept(visitor, traversal) if @id_list
  end
  
  def to_s
    return "IdentifierListNode -> [#{@id}, #{@id_list}]"
  end
end