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
  
  def to_s
    return "ConstantANode -> [#{@id} := #{@value} #{@const_a_node.to_s}]" unless @id.nil? and @value.nil? and @const_a_node.nil?
    return "ConstantANode -> #{@id} := #{@value}" unless @id.nil? and @value.nil?
  end
end