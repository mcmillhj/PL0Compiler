require_relative 'Node.rb'
class IdentANode < Node
  def initialize(id, ident_a_node)
    @id           = id
    @ident_a_node = ident_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def collect
    return { "IdentANode" => [@id, ",", @ident_a_node.collect] } if @ident_a_node and @id
    return { "IdentANode" => @id}                                if @id
    return {"IdentANode"  => nil}
  end
  
  def to_s
    return "IdentANode -> #{@id}, #{@ident_a_node.to_s}" if @id and @ident_a_node
    return "IdentANode -> #{@id}"                        if @id
    return "IdentANode -> e"
  end
end