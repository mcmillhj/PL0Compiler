class LengthNode < Node
  attr_reader :ident
  
  def initialize ident
    @ident = ident
  end

  def accept visitor 
    visitor.visit_length_node self
  end
  
  def to_s
    return "Length -> #{@ident}.length"
  end
end