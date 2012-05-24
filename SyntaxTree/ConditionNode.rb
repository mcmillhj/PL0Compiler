class ConditionNode < Node
  @expression_node_1 = nil
  @relop_node      = nil
  @expression_node_2 = nil
  
  def initialize(*args)
    if args.length == 1
      @expression_node_1 = args[0]
    else #args.length == 3
      @expression_node_1 = args[0]
      @relop_node        = args[1]
      @expression_node_2 = args[2]
    end
  end
  
  # todo
  def accept(visitor)
    
  end
end