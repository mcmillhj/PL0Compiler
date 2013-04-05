class CallStatementNode < StatementNode
  # id Name of the procedure to be called
  def initialize(name, params)
    @name   = name
    @params = params
  end
  
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    return "CallStatementNode -> call #{@name}(#{@params})"
  end
end