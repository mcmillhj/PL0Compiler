class RangeNode < Node
  attr_reader :start, :end
  
  def initialize(startval, endval)
    @start = startval
    @end   = endval 
  end
  
  # todo
  def accept(visitor, traversal = :pre)    
    
    @end.accept(visitor, traversal) if @end and @end.is_a? Node
    visitor.visit_range_node self
  end
  
  def to_s
    "Range -> #{@start}..#{@end}"
  end
end