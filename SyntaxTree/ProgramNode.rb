require_relative 'Node.rb'
class ProgramNode < Node
  def initialize(block_node)
    @block_node = block_node
  end
  
  # todo
  def accept(visitor)

  end
  
  def to_s
    return "ProgramNode -> #{@block_node.to_s}"
  end
end