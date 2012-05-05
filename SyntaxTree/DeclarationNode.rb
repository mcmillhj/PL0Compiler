class DeclarationNode < Node
  @const_declaration_node = nil
  @var_declaration_node   = nil
  @proc_declaration_node  = nil
  
  def initialize(const_decl_node, var_decl_node, proc_decl_node)
    @const_declaration_node = const_decl_node
    @var_declaration_node   = var_decl_node
    @proc_declaration_node  = proc_decl_node
  end
  
  # todo
  def accept(visitor)
    
  end
end