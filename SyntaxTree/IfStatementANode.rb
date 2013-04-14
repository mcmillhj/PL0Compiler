class IfStatementANode < StatementNode
  attr_reader :statement_node
  
  def initialize statement_node
    super self
    @statement_node = statement_node
  end
  
  def accept visitor   
    @statement_node.accept visitor if @statement_node
    
    visitor.visit_if_statement_a_node self
  end
  
  def to_s
    return "IfStatementANode -> else #{@statement_node.to_s}"
  end
end