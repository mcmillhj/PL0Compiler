require_relative 'Node.rb'
class AddSubOpNode < Node
  # either a plus or a minus
  def initialize(op, left = nil, right = nil)
    @op    = op
    @left  = left
    @right = right 
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def collect
    return {"AddSubOpNode" => [@left, @op, @right]}
  end
  
  def to_s
    return "AddSubOpNode -> #{@left} #{@op} #{@right}"
  end
end