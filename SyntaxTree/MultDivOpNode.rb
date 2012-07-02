require_relative 'Node.rb'
class MultDivOpNode < Node
  def initialize(op)
    @op = op  
  end
  
  # todo
  def accept(visitor)
    #TODO find something to do with @op
    visitor.visit_mult_div_op_node(self)  
  end
  
  def collect
    return {"MultDivOpNode" => @op}
  end
  
  def to_s
    return "MultDivOpNode -> #{@op}"
  end
end