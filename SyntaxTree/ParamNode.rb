class ParamNode < Node
  def initialize(id, type)
    @id   = id
    @type = type
  end
  
  def accept
    
  end
  
  def to_s
    "ParamNode -> #{@id} : #{@type}"
  end
end