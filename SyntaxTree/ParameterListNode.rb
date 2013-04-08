class ParameterListNode
  def initialize(param, param_list)
    @param      = param
    @param_list = param_list
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    visitor.visit_formal_param_list self if traversal == :pre
    
    @param.accept(visitor, traversal)      if @param
    @param_list.accept(visitor, traversal) if @param_list
    
    visitor.visit_formal_param_list self if traversal == :post
  end
  
  def to_s
    return "ParameterListNode -> [#{@param}, #{@param_list}]"
  end
end