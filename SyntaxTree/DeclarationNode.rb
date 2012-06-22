require_relative 'Node.rb'
class DeclarationNode < Node
  def initialize(const_decl_node, var_decl_node, proc_decl_node)
    @const_decl_node = const_decl_node
    @var_decl_node   = var_decl_node
    @proc_decl_node  = proc_decl_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def collect
    return {"DeclarationNode" => [@const_decl_node.collect, @var_decl_node.collect, @proc_decl_node.collect]} if @const_decl_node and @var_decl_node and @proc_decl_node
    return {"DeclarationNode" => [@const_decl_node.collect, @var_decl_node.collect]}                          if @const_decl_node and @var_decl_node
    return {"DeclarationNode" => [@const_decl_node.collect, @proc_decl_node.collect]}                         if @const_decl_node and @proc_decl_node
    return {"DeclarationNode" => [@var_decl_node.collect, @proc_decl_node.collect]}                           if @var_decl_node   and @proc_decl_node
    return {"DeclarationNode" => @const_decl_node.collect}                                                    if @const_decl_node
    return {"DeclarationNode" => @var_decl_node.collect}                                                      if @var_decl_node
    return {"DeclarationNode" => @proc_decl_node.collect}                                                     if @proc_decl_node
  end
  
  def to_s
    return "DeclarationNode -> #{@const_decl_node.to_s} #{@var_decl_node.to_s} #{@proc_decl_node.to_s}" if @const_decl_node and @var_decl_node and @proc_decl_node
    return "DeclarationNode -> #{@const_decl_node.to_s} #{@var_decl_node.to_s}"                         if @const_decl_node and @var_decl_node
    return "DeclarationNode -> #{@const_decl_node.to_s} #{@proc_decl_node.to_s}"                        if @const_decl_node and @proc_decl_node
    return "DeclarationNode -> #{@var_decl_node.to_s} #{@proc_decl_node.to_s}"                          if @var_decl_node and @proc_decl_node
    return "DeclarationNode -> #{@const_decl_node.to_s}"                                                if @const_decl_node
    return "DeclarationNode -> #{@var_decl_node.to_s}"                                                  if @var_decl_node
    return "DeclarationNode -> #{@proc_decl_node.to_s}"                                                 if @proc_decl_node
  end
end