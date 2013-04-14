class LogicalNegationNode < Node
  def initialize factor
    super()
    @factor = factor
  end
  
  def accept visitor
    @factor.accept visitor if @factor
    visitor.visit_logical_negation_node self
  end
end