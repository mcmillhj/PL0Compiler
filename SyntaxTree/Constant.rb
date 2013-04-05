class Constant < Node
  def initialize(id, val)
    @id, @val = id, val
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    "Constant -> #{@id} = #{@val}"
  end
end