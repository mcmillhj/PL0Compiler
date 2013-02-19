class ArrayNode
  def initialize(size, type)
    @size = size
    @type = type
  end
  
  def accept(visitor)
    
  end
  
  def collect
    return {"ArrayNode" => [@type.collect, size] }
  end
  
  def to_s
    "#{@type} array of size #{@size}"
  end
end