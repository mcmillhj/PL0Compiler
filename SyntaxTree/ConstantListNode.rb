require_relative 'Node.rb'
class ConstantListNode < Node
  def initialize(id, value, const_a_node)
    @id           = id
    @value        = value
    @const_a_node = const_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def to_s
    return "ConstantListNode -> #{@id} := #{@value} #{@const_a_node.to_s}"
  end
end