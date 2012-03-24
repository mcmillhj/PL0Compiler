#
# PL0Compiler.rb
# Main function for the compiler, starts execution
#
# Hunter McMillen
# 2/7/2012
##########################################################
require_relative 'Lexer/Tokenizer.rb'
require_relative 'Lexer/TokenType.rb'
require_relative 'Parser/Parser.rb'

# main function
if __FILE__ == $0
  t = Tokenizer.new(ARGV[0])
  p = Parser.new(t).parse
  PL0CompilerError.dump
end

