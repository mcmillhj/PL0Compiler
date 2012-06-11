require_relative 'Node.rb'
class IdentANode < Node
  def initialize(id, ident_a_node)
    @id           = id
    @ident_a_node = ident_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def to_s
    return "IdentANode -> #{@id}, #{@ident_a_node.to_s}" if not @id.nil? and not @ident_a_node.nil?
    return "IdentANode -> #{@id}" if @ident_a_node.nil?
    return "" if @id.nil?
  end
end