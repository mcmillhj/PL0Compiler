# Node.rb
# functions as the superclass for all the nodes of the AST 
# All subclasses of Node must implement the accept method for the Visitor pattern
# if they dont an exception will be raised by this class
require_relative 'Visited.rb'
class Node
  include Visited
  
  def collect
    raise NotImplementedError.new("Subclasses of Node must implement the collect method")
  end
end