class ConstantListNode < Node
  attr_reader :constant_list
  
  def initialize const_list
    super()
    @constant_list = const_list
  end
  
  def accept visitor
    # visit each constant in the list
    @constant_list.each do |const|
      const.accept visitor
    end
    
    visitor.visit_constant_list_node self
  end
  
  def to_s
    return "ConstantListNode -> #{@constant_list}"
  end
end