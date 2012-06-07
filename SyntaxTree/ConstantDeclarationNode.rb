require_relative 'Node.rb'
class ConstantDeclarationNode < Node
  def initialize(const_list_node)
    @const_list_node = const_list_node
  end
  
  # todo
  def accept(visitor)
    
  end
end