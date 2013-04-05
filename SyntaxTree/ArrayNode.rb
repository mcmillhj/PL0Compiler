class ArrayNode
  def initialize(size, type)
    @size = size
    @type = type
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    "#{@type} array of size #{@size}"
  end
end