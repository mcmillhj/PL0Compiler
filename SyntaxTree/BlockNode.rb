require_relative 'Node.rb'
class BlockNode < Node
  def initialize(decl_node, statement_node)
    @declaration_node = decl_node
    @statement_node   = statement_node
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "BlockNode -> #{@declaration_node.to_s} #{@statement_node.to_s}" if @declaration_node and @statement_node
    return "BlockNode -> #{@declaration_node.to_s}" if @declaration_node
    return "BlockNode -> #{@statement_node.to_s}"   if @statement_node
  end
end