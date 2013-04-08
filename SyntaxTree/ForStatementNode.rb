require_relative 'StatementNode.rb'
class ForStatementNode < StatementNode
  def initialize(id, range_node, statement_node)
    @id         = id
    @range_node = range_node
    @state_node = statement_node
  end
  
  def accept(visitor, traversal = :pre)
    visitor.visit_for_statement_node self if traversal == :pre

    @range_node.accept(visitor, traversal) if @range_node
    @state_node.accept(visitor, traversal) if @state_node
     
    visitor.visit_for_statement_node self if traversal == :post
  end
  
  def to_s
    "ForStatementNode -> for #{@id} in #{@range_node} #{@state_node}"
  end
end