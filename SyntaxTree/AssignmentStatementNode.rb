require_relative 'StatementNode.rb'

class AssignmentStatementNode < StatementNode
  attr_reader :id, :expr
  
  def initialize(id, expr)
    @id   = id
    @expr = expr
  end
  
  def accept(visitor, traversal = :pre)     
    # visit rvalues first
    @expr.accept(visitor, traversal) if @expr    
    
    visitor.visit_assign_statement_node self
  end
  
  def to_s
    return "AssignmentStatementNode -> #{@id} = #{@expr}"
  end
end