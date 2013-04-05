class VarListNode
  def initialize(var, var_list)
    @var      = var
    @var_list = var_list
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    
  end
  
  def to_s
    "VarList -> [#{@var} ; #{@var_list}]"
  end
end