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
  
  def collect
    return {"ConstantListNode" => [@id, ":=", @value, @const_a_node.collect]} if @const_a_node and @id and @value
    return {"ConstantListNode" => [@id, ":=", @value]}                        if @const_a_node and @id
    return {"ConstantListNode" => nil}
  end
  
  def to_s
    return "ConstantListNode -> [#{@id} := #{@value}, #{@const_a_node.to_s}]" if @const_a_node and @id and @value
    return "ConstantListNode -> #{@id} := #{@value}"                          if @const_a_node and @id 
  end
end