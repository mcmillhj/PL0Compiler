require_relative 'Node.rb'
class FactorNode < Node
  # value can represent an identifier, numeral, an ExpressionNode, or a StringLiteral
  def initialize(value)
    @value = value
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "FactorNode -> #{@value}"
  end
end