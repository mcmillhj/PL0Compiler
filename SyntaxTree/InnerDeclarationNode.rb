class InnerDeclarationNode < Node
  attr_reader :var_decl_node
  
  def initialize var_decl_node
    super()
    @var_decl_node = var_decl_node
  end
  
  def accept visitor  
    @var_decl_node.accept visitor if @var_decl_node
    
    visitor.visit_inner_declaration_node self
  end
  
  def to_s
    "InnerDeclarationNode -> #{@var_decl_node}"
  end
end