class FunctionNode < Node
  attr_reader :name, :param_list, :ret_type, :inner_block
  
  def initialize(name, param_list, return_type, inner_block_node)
    @name         = name
    @param_list   = param_list
    @ret_type     = return_type
    @inner_block  = inner_block_node
  end

  def accept visitor
    @param_list.accept visitor   if @param_list
    @ret_type.accept visitor     if @ret_type
    @inner_block.accept visitor  if @inner_block
    @func_decl.accept visitor    if @func_decl

    # visit this function FIRST, then the others
    visitor.visit_function_node self
  end

  def to_s
    "Function -> #{@name}(#{@param_list}) -> #{@ret_type}\n#{@func_decl}"
  end
end