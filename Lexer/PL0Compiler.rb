#
# PL0Compiler.rb
# Main function for the compiler, starts execution
#
# Hunter McMillen
# 2/7/2012
##########################################################
require_relative 'Tokenizer.rb'
require_relative 'TokenType.rb'
require_relative '../Parser/Parser.rb'
require_relative '../Parser/Sets.rb'
require 'pp'

# main function
if __FILE__ == $0
  t = Tokenizer.new(ARGV[0])
  p = Parser.new(t)
  tok = p.next_token
  puts tok.type == TokenType::IDENT_TOKEN
  token = Token.new(TokenType::CALL_TOKEN, 4, 'call')
  puts token.type === TokenType::CALL_TOKEN
end

