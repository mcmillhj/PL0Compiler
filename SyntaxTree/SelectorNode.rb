class SelectorNode < Node
  def initialize(array_name, index)
    @arr_name = array_name
    @index    = index
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    @index.accept(visitor, traversal) if @index and @index.is_a? ExpressionNode
    visitor.visit_selector_node self
  end
  
  def to_s
    "SelectorNode -> #{@arr_name}[#{@index}]"
  end
end