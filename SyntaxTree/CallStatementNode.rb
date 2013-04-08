class CallStatementNode < StatementNode
  attr_reader :name, :params
  # id Name of the procedure to be called
  def initialize(name, params)
    @name   = name
    @params = params
  end
  
  def accept(visitor, traversal = :pre)
    @params.accept(visitor, traversal) if @params
    visitor.visit_call_statement_node self
  end
  
  def to_s
    return "CallStatementNode -> call #{@name}(#{@params})"
  end
end