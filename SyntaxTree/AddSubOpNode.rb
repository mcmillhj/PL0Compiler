require_relative 'Node.rb'
class AddSubOpNode < Node
  # either a plus or a minus
  def initialize(op, left = nil, right = nil)
    @op    = op
    @left  = left
    @right = right 
  end
  
  # todo
  def accept(visitor)
    visitor.visit_add_sub_op_node(self)  
  end
  
  def collect
    return {"AddSubOpNode" => [@left, @op, @right]}
  end
  
  def to_s
    return "AddSubOpNode -> #{@left} #{@op} #{@right}"
  end
end