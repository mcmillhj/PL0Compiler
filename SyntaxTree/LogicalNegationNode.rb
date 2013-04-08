class LogicalNegationNode < Node
  def initialize(factor)
    @factor = factor
  end
  
  def accept(visitor, traversal = :pre)
    @factor.accept(visitor, traversal) if @factor
    visitor.visit_logical_negation_node self
  end
end