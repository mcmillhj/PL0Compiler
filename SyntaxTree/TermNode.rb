class TermNode < Node  
  attr_reader :value
  
  def initialize(value)
    @value = value
  end
  
  # todo
  def accept visitor
    @value.accept visitor if @value
    visitor.visit_term_node self
  end   
  
  def to_s
    return "TermNode -> #{@value}"
  end
end