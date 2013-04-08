class ParamNode < Node
  attr_reader :id, :type
  
  def initialize(id, type)
    @id   = id
    @type = type
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    visitor.visit_param_node self
  end
  
  def to_s
    "ParamNode -> #{@id} : #{@type}"
  end
end