class BooleanAndOrNode < Node
  def initialize(op, l = nil, r = nil)
    @op    = op
    @left  = l 
    @right = r
  end
  
  # todo
  def accept(visitor)
    #TODO find something to do with @option
  end
  
  def collect
    return {"BooleanAndOrNode" => [@left, @op, @right]}
  end 
  
  def to_s
    return "BooleanAndOrNode -> #{@left} #{@op} #{@right}"
  end
end