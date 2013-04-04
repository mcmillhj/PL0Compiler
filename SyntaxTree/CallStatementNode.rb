class CallStatementNode < StatementNode
  # id Name of the procedure to be called
  def initialize(name, params)
    @name   = name
    @params = params
  end
  
  # todo
  def accept(visitor)
    #TODO do something with @id
    visitor.visit_call_statement_node(self)  
  end
  
  def collect
    return {"CallStatementNode" => ["call", @name, @params]}
  end
  
  def to_s
    return "CallStatementNode -> call #{@name}(#{@params})"
  end
end