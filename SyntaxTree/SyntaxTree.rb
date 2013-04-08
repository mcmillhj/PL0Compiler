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
    @checker      = SemanticCheckVisitor.new
  end
  
  # checks the semantics of this AST
  def check    
    @checker.check @program_node
  end
end