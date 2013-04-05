class ParamNode < Node
  def initialize(id, type)
    @id   = id
    @type = type
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    "ParamNode -> #{@id} : #{@type}"
  end
end