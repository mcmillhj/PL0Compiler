require_relative 'Node.rb'
class VariableDeclarationNode < Node
  def initialize(var_list)
    @var_list = var_list
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "VariableDeclarationNode -> var #{@var_list}"
  end
end