class SelectorNode < Node
  def initialize(array_name, index)
    @arr_name = array_name
    @index    = index
  end
  
  def accept
    
  end
  
  def to_s
    "SelectorNode -> #{@arr_name}[#{@index}]"
  end
end