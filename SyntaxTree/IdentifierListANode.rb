require_relative 'Node.rb'
class IdentifierListANode < Node
  def initialize(id, ident_a_node)
    @id           = id
    @ident_a_node = ident_a_node
  end
  
  # todo
  def accept(visitor)
    #TODO something with @id
    @ident_a_node.accept(visitor) if @ident_a_node
    visitor.visit_identifier_a_node(self)    
  end
  
  def collect
    return { "IdentifierListANode" => [@id, ",", @ident_a_node.collect] } if @ident_a_node and @id
    return { "IdentifierListANode" => @id}                                if @id
    return { "IdentifierListANode" => nil}
  end
  
  def to_s
    return "IdentifierListANode -> #{@id}, #{@ident_a_node.to_s}" if @id and @ident_a_node
    return "IdentifierListANode -> #{@id}"                        if @id
    return "IdentifierListANode -> e"
  end
end