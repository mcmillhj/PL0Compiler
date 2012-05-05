class ConstantDeclarationNode < Node
  @const_list_node = nil
  
  def initialize(const_list_node)
    @const_list_node = const_list_node
  end
  
  # todo
  def accept(visitor)
    
  end
end