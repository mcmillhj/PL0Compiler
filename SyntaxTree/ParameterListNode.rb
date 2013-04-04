class ParameterListNode
  def initialize(param, param_list)
    @param      = param
    @param_list = param_list
  end
  
  def accept(visitor)

  end
  
  def collect

  end
  
  def to_s
    return "ParameterListNode -> [#{@param}, #{@param_list}]"
  end
end