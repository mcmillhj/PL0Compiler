class VarNode < Node
  attr_reader :type, :id_list
  
  def initialize(id_list, type)
    @id_list = id_list
    @type    = type
  end
  
  # todo
  def accept visitor
    @id_list.accept visitor if @id_list
    @type.accept visitor if @type
    
    visitor.visit_var_node self
  end
  
  def to_s
    "VarNode -> [#{@id_list} : #{@type}]"
  end
end