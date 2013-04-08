class VariableDeclarationNode < Node
  def initialize(var_list)
    @var_list = var_list
  end
  
  # todo
  def accept(visitor, traversal = :pre)    
    @var_list.accept(visitor, traversal) if @var_list
    visitor.visit_var_decl_node self
  end
  
  def to_s
    return "VariableDeclarationNode -> var #{@var_list}"
  end
end