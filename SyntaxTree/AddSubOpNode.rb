require_relative 'Node.rb'
class AddSubOpNode < Node
  # either a plus or a minus
  def initialize(op)
    @op = op 
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def to_s
    return "AddSubOpNode -> #{@op}\n"
  end
end