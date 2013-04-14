class VariableListNode
  attr_reader :var_list
  
  def initialize var_list
    super()
    @var_list = var_list
  end
  
  # todo
  def accept visitor 
    # visit all the vars in the list
    @var_list.each do |var|
      var.accept visitor
    end
    
    visitor.visit_var_list_node self
  end
  
  def to_s
    "VarList -> #{@var_list}"
  end
end