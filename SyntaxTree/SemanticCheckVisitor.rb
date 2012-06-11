require_relative '../Lexer/SymbolTable.rb'

class SemanticCheckVisitor < Visitor
  def initialize()
    @sym_table = SymbolTable.instance
  end
  
  # Make sure that the program is semantically correct
  def check(root)
    # use the visitor pattern to evaluate the AST nodes
    root.accept(self)
  end
  
  # visitor methods 
  
  
end