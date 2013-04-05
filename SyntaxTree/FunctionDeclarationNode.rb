class FunctionDeclarationNode < Node
  def initialize(id, param_list, return_type, block_node, func_decl)
    @id          = id
    @param_list  = param_list
    @ret_type    = return_type
    @block_node  = block_node
    @func_decl   = func_decl
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    
  end
end