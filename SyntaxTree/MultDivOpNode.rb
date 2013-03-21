require_relative 'Node.rb'
class MultDivOpNode < Node
  def initialize(op, left = nil, right = nil)
    @op    = op 
    @left  = left
    @right = right
  end
  
  # todo
  def accept(visitor)
    #TODO find something to do with @op
    visitor.visit_mult_div_op_node(self)  
  end
  
  def collect
    return {"MultDivOpNode" => [@left, @op, @right]}
  end
  
  def to_s
    return "MultDivOpNode -> #{@left} #{@op} #{right}"
  end
end