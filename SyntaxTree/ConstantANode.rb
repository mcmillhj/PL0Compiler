require_relative 'Node.rb'
class ConstantANode < Node
  def initialize(id, value, const_a_node)
    @id           = id
    @value        = value
    @const_a_node = const_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
end