#
# TokenizerError.rb
#
# Forwards errors and warnings from the Tokenizer program 
# to the compiler error log
######################################################################
require_relative '../PL0CompilerError.rb'

class TokenizerError < PL0CompilerError
  def self.warn(warn_string)
    tokenizer_warn_string = "Tokenizer: " + warn_string
    self.superclass.warn(tokenizer_warn_string)
  end
  
  def self.log(error_string)
    self.superclass.log("Tokenizer", error_string)
  end
end