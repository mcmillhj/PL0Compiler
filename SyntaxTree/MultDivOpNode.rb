require_relative 'Node.rb'
class MultDivOpNode < Node
  def initialize(op)
    @op = op  
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def to_s
    return "MultDivOpNode -> #{@op}"
  end
end