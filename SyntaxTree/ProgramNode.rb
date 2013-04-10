require_relative 'Node.rb'
class ProgramNode < Node
  attr_reader :name
  
  def initialize(program_name, block_node)
    @name       = program_name
    @block_node = block_node
  end
  
  # todo
  # todo
  def accept visitor
    @block_node.accept visitor if @block_node
    visitor.visit_program_node self
  end
  
  def to_s
    return "ProgramNode -> '#{@name}' #{@block_node.to_s} ." if @block_node
    return "ProgramNode -> 'program #{@name}' end"
  end
end