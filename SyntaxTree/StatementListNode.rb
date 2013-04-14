class StatementListNode < Node
  attr_reader :state_list
  
  def initialize state_list
    super()
    @state_list = state_list
  end
  
  def accept visitor
    # visit all the statements
    @state_list.each do |statement|
      statement.accept visitor if statement
    end
    
    visitor.visit_statement_list_node self
  end
  
  def to_s
    return "StatementListNode -> #{@state_list}"
  end
end