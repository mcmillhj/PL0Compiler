require_relative 'Node.rb'
class FunctionDeclarationNode < Node
  def initialize(func_a_node)
    @func_a_node = func_a_node
  end
  
  # todo
  def accept(visitor)
    @func_a_node.accept(visitor) if @func_a_node
    visitor.visit_procedure_decl_node(self)  
  end
  
  def collect
    return {"FunctionDeclarationNode" => @func_a_node.collect} if @func_a_node
    return {"FunctionDeclarationNode" => nil}
  end
  
  def to_s
    return "FunctionDeclarationNode -> #{@func_a_node.to_s}" if @func_a_node
    return "FunctionDeclarationNode -> e"
  end
end