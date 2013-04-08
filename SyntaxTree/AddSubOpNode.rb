require_relative 'Node.rb'

class AddSubOpNode < Node
  attr_reader :op, :left, :right
  # either a plus or a minus
  def initialize(op, left = nil, right = nil)
    @op    = op
    @left  = left
    @right = right 
  end
  
  def accept(visitor, traversal = :pre)
    @left.accept(visitor, traversal)  if @left
    @right.accept(visitor, traversal) if @right
    visitor.visit_add_sub_op_node self
  end
  
  def collect
    return {"AddSubOpNode" => [@left, @op, @right]}
  end
  
  def to_s
    return "AddSubOpNode -> #{@left} #{@op} #{@right}"
  end
end