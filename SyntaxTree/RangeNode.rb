class RangeNode < Node
  def initialize(startval, endval)
    @start = startval
    @end   = endval 
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    "Range -> #{@start}..#{@end}"
  end
end