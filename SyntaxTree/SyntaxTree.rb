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
    @checker      = SemanticCheckVisitor.new()
    @tree         = {}
  end
  
  # checks the semantics of this AST
  def check    
    @checker.check(@program_node)
  end
  
  # prints this AST to the console
  def printTree
    return @program_node.collect
  end
end