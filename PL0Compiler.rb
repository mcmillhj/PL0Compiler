#
# PL0Compiler.rb
# Main function for the compiler, starts execution
#
# Hunter McMillen
# 2/7/2012
##########################################################
require_relative 'Lexer/Tokenizer.rb'
require_relative 'Parser/Parser.rb'
require_relative 'Lexer/SymbolTable.rb'
require_relative 'Name/UpdateStack.rb'

# main function
if __FILE__ == $0
  # create the tokenizer
  t = Tokenizer.new(ARGV[3])
  # pass the tokenizer to the parser
  p = Parser.new(t).parse
  # print errors, if any
  PL0CompilerError.dump
  # grab the symbol table
  s = SymbolTable.instance
end

