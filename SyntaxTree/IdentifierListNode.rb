class IdentifierListNode < Node
  attr_reader :ids
  
  def initialize ids
    @ids = ids
  end
  
  def accept visitor
    visitor.visit_identifier_list_node self
  end
  
  def to_s
    return "IdentifierListNode -> [#{@ids}]"
  end
end