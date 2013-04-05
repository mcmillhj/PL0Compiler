class ParameterListNode
  def initialize(param, param_list)
    @param      = param
    @param_list = param_list
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "ParameterListNode -> [#{@param}, #{@param_list}]"
  end
end