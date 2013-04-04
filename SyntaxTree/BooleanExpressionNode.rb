class BooleanExpressionNode < Node
  def initialize(bool_and_or)
    @bool_expr = bool_and_or
  end
  
  # todo
  def accept(visitor)
    #TODO find something to do with @option
  end
  
  def collect
    return {"BooleanExpressionNode" => @bool_expr}
  end 
  
  def to_s
    return "BooleanExpressionNode -> #{@bool_expr}"
  end
end