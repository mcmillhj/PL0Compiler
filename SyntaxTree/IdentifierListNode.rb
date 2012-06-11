require_relative 'Node.rb'
class IdentifierListNode < Node
  def initialize(id, ident_a_node)
    @id           = id
    @ident_a_node = ident_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def to_s
    return "IdentifierListNode -> #{@id}\t#{@ident_a_node.to_s}\n"
  end
end