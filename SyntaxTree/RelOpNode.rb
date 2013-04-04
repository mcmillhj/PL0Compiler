require_relative 'Node.rb'
class RelOpNode < Node
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
    return {"RelopNode" => [@left, @op, @right]}
  end 
  
  def to_s
    return "RelopNode -> #{@left} #{@op} #{@right}"
  end
end