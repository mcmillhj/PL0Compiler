#
# SyntaxTree.rb
#
# This class represents the AST of a source program 
# its Nodes will be non-terminal symbols that correspond to functions 
# in the recursive descent parser
###########################################################################

class SyntaxTree
  def initialize(root)
    @program_node = root
  end
  
  # checks the semantics of this AST
  def check
    # create a new semantic checker
    checker = SemanticCheckVisitor.new()
    
    # check the semantics of the AST
    checker.check(@program_node)
  end
  
  # prints this AST to the console
  def print
    puts @program_node.to_s
  end
end