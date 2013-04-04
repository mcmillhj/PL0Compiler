class LengthNode < Node
  def initialize(array_name)
    @array_name = array_name
  end
  
  # todo
  def accept(visitor)

  end
  
  def collect
  end
  
  def to_s
    return "Length -> #{@array_name}.length"
  end
end