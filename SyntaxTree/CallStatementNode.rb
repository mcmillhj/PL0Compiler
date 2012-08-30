class CallStatementNode < StatementNode
  # id Name of the procedure to be called
  def initialize(id)
    @id = id
  end
  
  # todo
  def accept(visitor)
    #TODO do something with @id
    visitor.visit_call_statement_node(self)  
  end
  
  def collect
    return {"CallStatementNode" => ["call", @id]}
  end
  
  def to_s
    return "CallStatementNode -> call #{@id}"
  end
end