require_relative 'StatementNode.rb'

class ForStatementNode < StatementNode
  attr_reader :state_node
  
  def initialize(id, range_node, statement_node)
    super self
    @id         = id
    @range_node = range_node
    @state_node = statement_node
  end
  
  def accept visitor
    @range_node.accept visitor if @range_node
    @state_node.accept visitor if @state_node
     
    visitor.visit_for_statement_node self
  end
  
  def to_s
    "ForStatementNode -> for #{@id} in #{@range_node} #{@state_node}"
  end
end