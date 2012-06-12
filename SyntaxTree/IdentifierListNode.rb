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
    return "IdentifierListNode -> [#{@id}, #{@ident_a_node.to_s}]" unless @ident_a_node.nil? and  @id.nil?
    return "IdentiferListNode  -> #{@id}" unless @id.nil?
  end
end