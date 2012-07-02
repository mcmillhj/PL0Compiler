require_relative 'Node.rb'
class StringLiteralNode < Node
  def initialize(text)
    @text = text
  end
  
  # todo
  def accept(visitor)
    #TODO find something to do with text
    visitor.visit_string_literal_node(self)  
  end
  
  def collect
    return {"StringLiteralNode" => @text}
  end
  
  def to_s
    return "StringLiteralNode -> \"#{@text}\""
  end
end