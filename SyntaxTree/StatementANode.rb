require_relative 'Node.rb'
class StatementANode < Node
  def initialize(state_node, state_a_node)
    @statement_node    = state_node
    @statement_a_node = state_a_node
  end
  
  # todo
  def accept(visitor)
    @statement_node.accept(visitor)      if @statement_node
    @statement_a_node.accept(visitor)    if @statement_a_node
    visitor.visit_statement_a_node(self) 
  end
  
  def collect
    return {"StatementANode" => [@statement_node.collect, @statement_a_node.collect]} if @statement_node and @statement_a_node
    return {"StatementANode" => [@statement_node.collect]}                            if @statement_node
    return {"StatementANode" => nil}
  end
  
  def to_s
    return "StatementANode -> ; #{@statement_node.to_s} #{@statement_a_node.to_s}" if @statement_node and @statement_a_node
    return "StatementANode -> ; #{@statement_node.to_s}"                           if @statement_node
    return "StatementANode -> e"
  end
end