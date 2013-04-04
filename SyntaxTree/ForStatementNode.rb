require_relative 'StatementNode.rb'
class ForStatementNode < StatementNode
  def initialize(id, iterable_node, statement_node)
    @id         = id
    @it_node    = iterable_node
    @state_node = statement_node
  end
  
  def accept
    
  end
  
  def collect
    
  end
  
  def to_s
    "ForStatementNode -> #{@id} #{@it_node} #{@state_node}"
  end
end