require_relative 'Node.rb'
class StringLiteralNode < Node
  def initialize(text)
    @text = text
  end
  
  # todo
  def accept(visitor)
    
  end
end