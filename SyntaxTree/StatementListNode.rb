require_relative 'Node.rb'

class StatementListNode < Node
  def initialize(state_node, state_a_node)
    @statement_node    = state_node
    @statement_a_node = state_a_node
  end
  
  # todo
  def accept(visitor)
    
  end
  
  def collect
    return {"StatementListNode" => [@statement_node.collect, @statement_a_node.collect]} if @statement_node and @statement_a_node
    return {"StatementListNode" => [@statement_node.collect]}                            if @statement_node
    return {"StatementListNode" => nil}
  end
  
  def to_s
    return "StatementListNode -> #{@statement_node.to_s} #{@statement_a_node.to_s}" if @statement_node and @statement_a_node
    return "StatementListNode -> #{@statement_node.to_s}"                           if @statement_node
    return "StatementListNode -> e"
  end
end