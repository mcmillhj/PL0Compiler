class ParameterListNode < Node
  attr_reader :param_list
  
  def initialize param_list
    super()
    @param_list = param_list
  end
  
  # todo
  def accept visitor
    # visit all the parameters
    @param_list.each do |param|
      param.accept visitor
    end
    
    visitor.visit_formal_param_list self
  end
  
  def types
    @param_list.map{|p| p.get_type}
  end
  
  def names
    @param_list.map{|p| p.get_name}
  end
  
  def to_s
    return "ParameterListNode -> #{@param_list}"
  end
end