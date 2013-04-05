require_relative 'Node.rb'
class ConstantDeclarationNode < Node
  def initialize(const_list_node)
    @const_list_node = const_list_node
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "ConstantDeclarationNode -> const #{@const_list_node.to_s} ;"
  end
end