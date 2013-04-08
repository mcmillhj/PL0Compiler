require_relative 'Node.rb'
class ConstantDeclarationNode < Node
  def initialize(const_list_node)
    @const_list_node = const_list_node
  end
  
  def accept(visitor, traversal = :pre)    
    @const_list_node.accept(visitor, traversal) if @const_list_node
    
    visitor.visit_const_declaration_node self
  end
  
  def to_s
    return "ConstantDeclarationNode -> const #{@const_list_node.to_s} ;"
  end
end