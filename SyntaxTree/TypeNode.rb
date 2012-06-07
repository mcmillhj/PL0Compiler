require_relative 'Node.rb'
class TypeNode < Node
  def initialize(type)
    @type = type
  end
  
  # todo
  def accept(visitor)
    
  end
end