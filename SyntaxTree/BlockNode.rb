require_relative 'Node.rb'
class BlockNode < Node
  def initialize(decl_node, statement_node)
    @declaration_node = decl_node
    @statement_node   = statement_node
  end
  
  # todo
  def accept(visitor)
    @declaration_node.accept(visitor) unless @declaration_node.nil?
    @statement_node.accept(visitor)   unless @statement_node.nil?
    visitor.visit_block_node(self)
  end
  
  def collect
    return {"BlockNode" => [@declaration_node.collect, @statement_node.collect]} if @declaration_node and @statement_node
    return {"BlockNode" => [@declaration_node.collect]} if @declaration_node
    return {"BlockNode" => [@statement_node.collect]}   if @statement_node
  end
  
  def to_s
    return "BlockNode -> #{@declaration_node.to_s} #{@statement_node.to_s}" if @declaration_node and @statement_node
    return "BlockNode -> #{@declaration_node.to_s}" if @declaration_node
    return "BlockNode -> #{@statement_node.to_s}"   if @statement_node
  end
end