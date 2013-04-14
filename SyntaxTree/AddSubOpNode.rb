require_relative 'Node.rb'

class AddSubOpNode < Node
  attr_reader :op, :left, :right
  
  # either a plus or a minus
  def initialize(op, left = nil, right = nil)
    super()
    @op    = op
    @left  = left
    @right = right 
  end
  
  def accept visitor
    @left.accept visitor  if @left
    @right.accept visitor if @right
    
    visitor.visit_add_sub_op_node self
  end
  
  def collect
    return {"AddSubOpNode" => [@left, @op, @right]}
  end
  
  def to_s
    return "AddSubOpNode -> #{@left} #{@op} #{@right}"
  end
end