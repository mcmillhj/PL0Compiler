require_relative 'Node.rb'
class ConstantDeclarationNode < Node
  def initialize(const_list_node)
    @const_list_node = const_list_node
  end
  
  # todo
  def accept(visitor)
    @const_list_node.accept(visitor)
    visitor.visit_const_declaration_node(self)  
  end
  
  def collect
    return {"ConstantDeclarationNode" => @const_list_node.collect}
  end
  
  def to_s
    return "ConstantDeclarationNode -> const #{@const_list_node.to_s} ;"
  end
end