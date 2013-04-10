class FunctionListNode < Node
  attr_reader :func_list
  
  def initialize func_list
    @func_list = func_list
  end
  
  def accept visitor
    @func_list.each do |func|
      func.accept visitor if func
    end
    
    visitor.visit_function_list_node self
  end
end