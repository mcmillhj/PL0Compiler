class ConstantNode < Node
  attr_reader :id, :val
  
  def initialize(id, val)
    @id, @val = id, val
  end
  
  # no need to recurse here because 
  # constants only contain terminal values
  def accept(visitor, traversal = :pre)
    visitor.visit_constant_node self
  end
  
  def to_s
    "Constant -> #{@id} = #{@val.text}"
  end
end