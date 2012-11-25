class ParameterListNode
  def initialize(ident, type, param_list)
    @id         = ident
    @type       = type
    @param_list = param_list
  end
  
  def accept(visitor)
    visitor.visit_param_list_node(self)
    @param_list.accept(visitor) if @param_list
  end
  
  def collect
    return {"ParameterListNode" => [@id, @param_list.collect]} if @param_list and @id
    return {"ParameterListNode" => @id}                        if @id
  end
  
  def to_s
    return "ParameterListNode -> [#{@id}, #{@param_list}]" if @param_list and @id
    return "ParameterListNode  -> #{@id}"                  if @id   
  end
end