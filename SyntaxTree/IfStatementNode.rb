require_relative 'StatementNode.rb'

class IfStatementNode < StatementNode
  def initialize(cond_node, statement_node, if_statement_a)
    @condition_node      = cond_node
    @statement_node      = statement_node
    @if_statement_a_node = if_statement_a
  end
  
  # TODO implement accept
  def accept(visitor)
    @condition_node.accept(visitor) 
    @statement_node.accept(visitor)      if @statement_node
    @if_statement_a_node.accept(visitor) if @if_statement_a_node
    visitor.visit_if_statement_node(self)  
  end
  
  def collect
    return {"IfStatementNode" => ["if", @condition_node.collect,"then", @statement_node.collect, @if_statement_a_node.collect]} if @if_statement_a_node and @statement_node
    return {"IfStatementNode" => ["if", @condition_node.collect,"then", @statement_node.collect]} if @statement_node
    return {"IfStatementNode" => ["if", @condition_node.collect,"then"]} 
  end
  
  def to_s
    return "IfStatementNode -> if #{@condition_node.to_s} then #{@statement_node.to_s} #{@if_statement_a_node.to_s}" if @if_statement_a_node
    return "IfStatementNode -> if #{@condition_node.to_s} then #{@statement_node.to_s}"                              if @statment_node
    return "IfStatementNode -> if #{@condition_node.to_s} then"
  end
end