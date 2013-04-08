class VarListNode
  def initialize(var, var_list)
    @var      = var
    @var_list = var_list
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    @var.accept(visitor, traversal)      if @var
    @var_list.accept(visitor, traversal) if @var_list
    
    visitor.visit_var_list_node self
  end
  
  def to_s
    "VarList -> #{@var}, #{@var_list}"
  end
end