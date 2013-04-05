require_relative '../Lexer/SymbolTable.rb'
require_relative 'Visitor.rb'
class SemanticCheckVisitor < Visitor
  def initialize()
    @sym_table = SymbolTable.instance
    @name      = "unknown"
    @procs     = []
    @vars      = []
  end

  # Make sure that the program is semantically correct
  def check(root)
    # use the visitor pattern to evaluate the AST nodes
    root.accept(self)
  end

  #####################################
  # visitor methods
  #####################################
  
end