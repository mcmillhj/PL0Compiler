# Node.rb
# functions as the superclass for all the nodes of the AST 
# All subclasses of Node must implement the accept method for the Visitor pattern
# if they dont an exception will be raised by this class
class Node  
  attr_accessor :type
  
  def initialize
    @type = nil
  end
  
  def accept visitor
    raise NotImplementedError.new("Subclasses of Node must implement the accept method")
  end
  
  def to_s
    raise NotImplementedError.new("Subclasses of Node must implement the to_s method")
  end
end