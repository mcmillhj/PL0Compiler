require_relative 'Node.rb'
class VariableDeclarationNode < Node
  def initialize(id_list_node, type_node)
    @id_list_node = id_list_node
    @type_node    = type_node
  end
  
  # todo
  def accept(visitor)
    @id_list_node.accept(visitor)  
    @type_node.accept(visitor)
    visitor.visit_var_decl_node(self);
  end
  
  def collect
    return {"VariableDeclarationNode" => ["var", @id_list_node.collect, ":", @type_node.collect]}
  end
  
  def to_s
    return "VariableDeclarationNode -> var #{@id_list_node.to_s} : #{@type_node.to_s} ;"
  end
end