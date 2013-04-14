class InnerBlockNode < Node
  attr_reader :inner_declaration_node, :statement_node
  
  def initialize(inner_decl_node, statement_node)
    super()
    @inner_declaration_node = inner_decl_node
    @statement_node         = statement_node
  end
  
  def accept visitor 
    @inner_declaration_node.accept visitor if @inner_declaration_node
    @statement_node.accept visitor         if @statement_node
    
    visitor.visit_inner_block_node self
  end
  
  def to_s
    return "InnerBlockNode -> #{@inner_declaration_node} #{@statement_node}" if @inner_declaration_node and @statement_node
    return "InnerBlockNode -> #{@inner_declaration_node}"                    if @inner_declaration_node
    return "BlockNode -> #{@statement_node}"                            if @statement_node
  end
end