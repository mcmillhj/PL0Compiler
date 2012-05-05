class VariableDeclarationNode < Node
  @id_list_node = nil
  @type_node    = nil
  
  def initialize(id_list_node, type_node)
    @id_list_node = id_list_node
    @type_node    = type_node
  end
  
  # todo
  def accept(visitor)
    
  end
end