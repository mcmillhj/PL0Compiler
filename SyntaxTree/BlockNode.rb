class BlockNode < Node
  def initialize(decl_node, statement_node)
    @declaration_node = decl_node
    @statement_node   = statement_node
  end
  
  def accept visitor    
    @declaration_node.accept visitor if @declaration_node
    @statement_node.accept visitor   if @statement_node
    
    visitor.visit_block_node self
  end
  
  def to_s
    return "BlockNode -> #{@declaration_node.to_s} #{@statement_node.to_s}" if @declaration_node and @statement_node
    return "BlockNode -> #{@declaration_node.to_s}" if @declaration_node
    return "BlockNode -> #{@statement_node.to_s}"   if @statement_node
  end
end