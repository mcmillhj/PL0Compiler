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
  
  def collect
    return {"ConstantANode" => [@id, ":=", @value.collect, @const_a_node.collect]} if @id and @value and @const_a_node
    return {"ConstantANode" => [@id, ":=", @value.collect]}                        if @id and @value
    return {"ConstantANode" => nil}
  end
    
  def to_s
    return "ConstantANode -> [#{@id} := #{@value.to_s} #{@const_a_node.to_s}]" if @id and @value and @const_a_node
    return "ConstantANode -> #{@id} := #{@value}"                         if @id and @value
  end
end