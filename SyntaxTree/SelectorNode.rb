class SelectorNode < Node
  attr_reader :array, :index
  
  def initialize(array, index)
    @array = array
    @index = index
  end
  
  # todo
  def accept visitor 
    @index.accept visitor if @index and @index.is_a? ExpressionNode
    visitor.visit_selector_node self
  end
  
  def to_s
    "SelectorNode -> #{@array}[#{@index}]"
  end
end