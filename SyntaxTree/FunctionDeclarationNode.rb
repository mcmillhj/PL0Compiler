class FunctionDeclarationNode < Node
  attr_reader :function_list_node
  
  def initialize function_list_node
    super()
    @function_list_node = function_list_node
  end

  def accept visitor
    @function_list_node.accept visitor

    # visit this function FIRST, then the others
    visitor.visit_function_decl_node self
  end

  def to_s
    "FunctionDeclarationNode -> #{@function_list_node}"
  end
end