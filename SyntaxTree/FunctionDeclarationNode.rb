class FunctionDeclarationNode < Node
  attr_reader :name, :param_list, :ret_type, :inner_block_node, :func_decl
  def initialize(name, param_list, return_type, inner_block_node, func_decl)
    @name              = name
    @param_list        = param_list
    @ret_type          = return_type
    @inner_block_node  = inner_block_node
    @func_decl         = func_decl
  end

  def accept(visitor, traversal = :pre)
    @param_list.accept(visitor, traversal)        if @param_list
    @ret_type.accept(visitor, traversal)          if @ret_type
    @inner_block_node.accept(visitor, traversal)  if @inner_block_node
    @func_decl.accept(visitor, traversal)         if @func_decl

    # visit this function FIRST, then the others
    visitor.visit_function_decl_node self
  end

  def to_s
    "FunctionDeclaration -> #{@name}(#{@param_list}) -> #{@ret_type}\n#{@func_decl}"
  end
end