require_relative 'Node.rb'
class IdentifierListNode < Node
  def initialize(id, ident_a_node)
    @id           = id
    @ident_a_node = ident_a_node
  end
  
  # todo
  def accept(visitor)
    #TODO something with @id
    visitor.visit_identifier_a_node(self)  
    @ident_a_node.accept(visitor) if @ident_a_node
  end
  
  def collect
    return {"IdentifierListNode" => [@id, @ident_a_node.collect]} if @ident_a_node and @id
    return {"IdentifierListNode" => @id}                          if @id
  end
  
  def to_s
    return "IdentifierListNode -> [#{@id}, #{@ident_a_node}]" if @ident_a_node and @id
    return "IdentiferListNode  -> #{@id}"                     if @id
  end
end