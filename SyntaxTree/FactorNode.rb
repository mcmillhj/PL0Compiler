require_relative 'Node.rb'
class FactorNode < Node
  # value can represent an identifier, numeral, an ExpressionNode, or a StringLiteral
  def initialize(value)
    @value = value
  end
  
  # todo
  def accept(visitor)
    
  end
end