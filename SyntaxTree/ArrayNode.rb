class ArrayNode
  def initialize(size, type)
    @size = size
    @type = type
  end
  
  def accept(visitor, traversal = :pre)
    visitor.visit_array_node self
  end
  
  def to_s
    "#{@type} array of size #{@size}"
  end
end