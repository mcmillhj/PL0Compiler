class VarNode < Node
  def initialize(id_list, type)
    @id_list = id_list
    @type    = type
  end
  
  def accept
    
  end
  
  def to_s
    "VarNode -> [#{@id_list} : #{@type}]"
  end
end