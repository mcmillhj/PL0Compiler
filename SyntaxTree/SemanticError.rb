#
# SemanticError.rb
#
# Forwards errors and warnings from the SyntaxTree program 
# to the compiler error log
######################################################################
require_relative '../PL0Compiler.rb'
class SemanticError < PL0CompilerError
  def self.warn(warn_string)
    tokenizer_warn_string = "Semantic Analyzer: " + warn_string
    self.superclass.warn(tokenizer_warn_string)
  end
  
  def self.log(error_string)
    self.superclass.log("Semantic Analyzer", error_string)
  end
end
