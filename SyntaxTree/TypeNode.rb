class TypeNode < Node
  @type = nil
  
  def initialize(type)
    @type = type
  end
  
  # todo
  def accept(visitor)
    
  end
end