require_relative 'Node.rb'
class DeclarationNode < Node
  def initialize(const_decl_node, var_decl_node, proc_decl_node)
    @const_declaration_node = const_decl_node
    @var_declaration_node   = var_decl_node
    @proc_declaration_node  = proc_decl_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def to_s
    return "DeclarationNode -> #{@const_declaration_node}\t#{@var_declaration_node}\t#{@proc_declaration_node}\n"
  end
end