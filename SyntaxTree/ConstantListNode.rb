class ConstantListNode < Node
  def initialize(const, const_list)
    @constant = const
    @constant_list = const_list
  end
  
  def accept(visitor, traversal = :pre)
    visitor.visit_constant_list_node self if traversal == :pre
    
    @constant.accept(visitor, traversal)      if @constant
    @constant_list.accept(visitor, traversal) if @constant_list
    
    visitor.visit_constant_list_node self if traversal == :post
  end
  
  def to_s
    return "ConstantListNode -> [#{@constant}, #{@constant_list}]"
  end
end