require_relative 'Node.rb'
class VariableDeclarationNode < Node
  def initialize(id_list_node, type_node)
    @id_list_node = id_list_node
    @type_node    = type_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def to_s
    return "VariableDeclarationNode -> #{@id_list_node}\t#{@type_node}\n"
  end
end