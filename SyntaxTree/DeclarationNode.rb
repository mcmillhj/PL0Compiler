require_relative 'Node.rb'
class DeclarationNode < Node
  def initialize(const_decl_node, var_decl_node, proc_decl_node)
    @const_decl_node = const_decl_node
    @var_decl_node   = var_decl_node
    @proc_decl_node  = proc_decl_node
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "DeclarationNode -> #{@const_decl_node.to_s} #{@var_decl_node.to_s} #{@proc_decl_node.to_s}"
  end
end