require_relative 'Node.rb'
class IdentifierListNode < Node
  def initialize(id, ident_a_node)
    @id           = id
    @ident_a_node = ident_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def collect
    return {"IdentifierListNode" => [@id, @ident_a_node.collect]} if @ident_a_node and @id
    return {"IdentifierListNode" => @id}                               if @id
  end
  
  def to_s
    return "IdentifierListNode -> [#{@id}, #{@ident_a_node.to_s}]" if @ident_a_node and @id
    return "IdentiferListNode  -> #{@id}"                          if @id
  end
end