require_relative 'Node.rb'
class TypeNode < Node
  def initialize(type)
    @type = type
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def collect
    return {"TypeNode" => @type}
  end
  
  def to_s
    return "TypeNode -> #{@type}"
  end
end