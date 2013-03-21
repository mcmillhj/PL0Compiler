require_relative 'Node.rb'
class ExpressionNode < Node
  def initialize(add_sub_op)
    @add_sub_node = add_sub_op
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def collect
    return {"ExpressionNode" => @add_sub_node.collect}  
  end
  
  def to_s
    return "ExpressionNode -> #{@add_sub_node}"
  end
end