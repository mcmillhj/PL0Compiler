require_relative 'Node.rb'
class BlockNode < Node
  def initialize(decl_node, statement_node)
    @declaration_node = decl_node
    @statement_node   = statement_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def to_s
    return "BlockNode -> #{@declaration_node.to_s} #{@statement_node.to_s}"
  end
end