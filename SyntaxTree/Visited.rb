# Defines the contract for objects that can be 'visited' 
# by a 'visitor' 
# A visitor knows how to visit each 
##################################################
module Visited
  def accept(visitor)
    raise NotImplementedError.new("Subclasses of Node must implement the accept method")
  end
end