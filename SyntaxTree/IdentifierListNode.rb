require_relative 'Node.rb'
class IdentifierListNode < Node
  def initialize(id, ident_list)
    @id         = id
    @ident_list = ident_list
  end
  
  # todo
  def accept(visitor)

  end
  
  def collect

  end
  
  def to_s
    return "IdentifierListNode -> [#{@id}, #{@ident_list}]"
  end
end