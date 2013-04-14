class TypeNode < Node
  attr_reader :type
  
  def initialize type
    super()
    @type = type
  end
  
  # todo
  def accept visitor
    visitor.visit_type_node self
  end
  
  def to_s
    return "TypeNode -> #{@type}"
  end
end