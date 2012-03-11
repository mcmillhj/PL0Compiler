#
# Parser.rb
#
# Parses the syntax of the input file using the recursive descent method
# logs all errors and prints after parsing is completed
#
# author:  Hunter McMillen
# version: V1, 3/10/2012
######################################################################
require_relative '../Lexer/Tokenizer.rb'
require_relative '../Lexer/TokenType.rb'

class Parser
  @sym = nil
  def initialize(tokenizer)
    @tokenizer = tokenizer
  end
  
  # Asks the tokenizer for the next token 
  # in the input file
  def next_token()
    sym = @tokenizer.next_token()
  end
end
