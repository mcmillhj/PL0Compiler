require_relative 'Node.rb'
class RelOpNode < Node
  def initialize(op)
    @op = op
  end
  
  # todo
  def accept(visitor)
    
  end
end