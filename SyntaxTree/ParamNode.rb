class ParamNode < Node
  attr_reader :id, :type
  
  def initialize(id, type)
    @id   = id
    @type = type
  end
  
  # todo
  def accept visitor
    @id.accept visitor   if @id.is_a? ArrayNode
    @type.accept visitor if @type
    
    visitor.visit_param_node self
  end
  
  def get_type
    @type.type
  end
  
  def to_s
    "ParamNode -> #{@id} : #{@type}"
  end
end