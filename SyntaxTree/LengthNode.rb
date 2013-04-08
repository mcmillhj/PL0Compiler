class LengthNode < Node
  def initialize(array_name)
    @array_name = array_name
  end

  def accept(visitor, traversal = :pre)
    visitor.visit_length_node self
  end
  
  def to_s
    return "Length -> #{@array_name}.length"
  end
end