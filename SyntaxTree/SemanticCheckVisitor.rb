require_relative '../Lexer/SymbolTable.rb'
require_relative 'Visitor.rb'

class SemanticCheckVisitor < Visitor
  def initialize()
    @sym_table = SymbolTable.instance
    @name      = "unknown"
  end
  
  # Make sure that the program is semantically correct
  def check(root)
    # use the visitor pattern to evaluate the AST nodes
    root.accept(self)
  end
  
  # visitor methods 
  def visit_program_node(program_node)
    @name = program_node.name
  end
  
  def visit_block_node(block_node)
    
  end
end