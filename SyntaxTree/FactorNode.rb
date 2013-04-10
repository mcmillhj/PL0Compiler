class FactorNode < Node
  attr_reader :value
  
  def initialize value
    @value = value
  end
  
  def accept visitor
    @value.accept visitor if @value and @value.is_a? Node
    visitor.visit_factor_node self 
  end
  
  def to_s
    return "FactorNode -> #{@value}"
  end
end