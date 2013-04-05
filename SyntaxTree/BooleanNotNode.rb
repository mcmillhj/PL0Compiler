class BooleanNotNode < Node
  def initialize(factor)
    @factor = factor
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    "BooleanNot -> ! #{@factor}"
  end
end