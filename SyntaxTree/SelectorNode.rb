class SelectorNode < Node
  def initialize(array_name, index)
    @arr_name = array_name
    @index    = index
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    "SelectorNode -> #{@arr_name}[#{@index}]"
  end
end