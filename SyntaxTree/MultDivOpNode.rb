require_relative 'Node.rb'
class MultDivOpNode < Node
  def initialize(op, left = nil, right = nil)
    @op    = op 
    @left  = left
    @right = right
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "MultDivOpNode -> #{@left} #{@op} #{@right}"
  end
end