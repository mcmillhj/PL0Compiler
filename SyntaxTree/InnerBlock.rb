class InnerBlockNode < Node
  def initialize(inner_decl_node, statement_node)
    @inner_declaration_node = inner_decl_node
    @statement_node         = statement_node
  end
  
  def accept(visitor, traversal = :pre)    
    @inner_declaration_node.accept(visitor, traversal) if @inner_declaration_node
    @statement_node.accept(visitor, traversal)         if @statement_node
    
    visitor.visit_inner_block_node self
  end
  
  def to_s
    return "BlockNode -> #{@inner_declaration_node} #{@statement_node}" if @inner_declaration_node and @statement_node
    return "BlockNode -> #{@inner_declaration_node}"                    if @inner_declaration_node
    return "BlockNode -> #{@statement_node}"                            if @statement_node
  end
end