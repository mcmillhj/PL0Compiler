require_relative 'Node.rb'
class TermNode < Node
  def initialize(mult_div_op)
    @mult_div_node = mult_div_op
  end
  
  # todo
  def accept(visitor)
  end
  
  def collect
    return {"TermNode" => @mult_div_node.collect}
  end
  
  def to_s
    return "TermNode -> #{@mult_div_node}"
  end
end