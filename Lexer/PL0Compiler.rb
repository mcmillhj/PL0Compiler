#
# PL0Compiler.rb
# Main function for the compiler, starts execution
#
# Hunter McMillen
# 2/7/2012
##########################################################
require_relative 'Tokenizer.rb'

# main function
if __FILE__ == $0
  infilename = ARGV[0]
  t = Tokenizer.new(infilename).tokenize()
end

