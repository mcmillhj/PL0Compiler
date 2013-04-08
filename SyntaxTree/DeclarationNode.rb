class DeclarationNode < Node
  def initialize(const_decl_node, var_decl_node, func_decl_node)
    @const_decl_node = const_decl_node
    @var_decl_node   = var_decl_node
    @func_decl_node  = func_decl_node
  end
  
  def accept(visitor, traversal = :pre)    
    @const_decl_node.accept(visitor, traversal) if @const_decl_node
    @var_decl_node.accept(visitor, traversal)   if @var_decl_node
    @func_decl_node.accept(visitor, traversal)  if @func_decl_node
    
    visitor.visit_declaration_node self
  end
  
  def to_s
    "DeclarationNode -> #{@const_decl_node} #{@var_decl_node} #{@func_decl_node}"
  end
end