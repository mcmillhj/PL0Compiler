class ArrayNode < Node
  attr_reader :size, :arr_type
  
  def initialize(size, type)
    @size     = size
    @arr_type = type
  end
  
  def accept visitor
    @arr_type.accept visitor if @arr_type
    visitor.visit_array_node self
  end
  
  def to_s
    "#{@arr_type} array of size #{@size}"
  end
end