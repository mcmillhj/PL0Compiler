class VarNode < Node
  attr_reader :type, :id_list
  
  def initialize(id_list, type)
    @id_list = id_list
    @type    = type
  end
  
  # todo
  def accept(visitor, traversal = :pre)
    @id_list.accept(visitor, traversal) if @id_list
    @type.accept(visitor, traversal)    if @type
    
    visitor.visit_var_node self
  end
  
  def to_s
    "VarNode -> [#{@id_list} : #{@type}]"
  end
end