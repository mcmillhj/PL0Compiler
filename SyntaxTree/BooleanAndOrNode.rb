class BooleanAndOrNode < Node
  def initialize(op, l = nil, r = nil)
    @op    = op
    @left  = l 
    @right = r
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "BooleanAndOrNode -> #{@left} #{@op} #{@right}"
  end
end