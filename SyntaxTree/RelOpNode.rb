require_relative 'Node.rb'
class RelOpNode < Node
  def initialize(op)
    @op = op
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def collect
    return {"RelopNode" => @op}
  end 
  
  def to_s
    return "RelopNode -> #{@op}"
  end
end