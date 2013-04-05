require_relative 'Node.rb'
class TermNode < Node
  attr_accessor :negated
  
  def initialize(mult_div_op)
    @mult_div_node = mult_div_op
    @negated       = false
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "TermNode -> #{@mult_div_node}"
  end
end