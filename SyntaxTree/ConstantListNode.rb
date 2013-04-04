require_relative 'Node.rb'
class ConstantListNode < Node
  def initialize(const, const_liste)
    @constant = const
    @constant_list = const_list
  end
  
  # todo
  def accept(visitor)
  
  end
  
  def collect

  end
  
  def to_s
    return "ConstantListNode -> [#{@constant}, #{@constant_list}]"
  end
end