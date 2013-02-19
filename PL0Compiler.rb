#
# PL0Compiler.rb
# Main function for the compiler, starts execution
#
# Hunter McMillen
# 2/7/2012
##########################################################
require_relative 'Lexer/Tokenizer.rb'
require_relative 'Lexer/SymbolTable.rb'
Dir[File.dirname(__FILE__) + '/SyntaxTree/*.rb'].each {|file| require_relative file} # for some reason I need this before 'require Parser/Parser.rb'
require_relative 'Parser/Parser.rb'
require_relative 'Name/UpdateStack.rb'

SYMBOL = true

# Entry point into the compiler
# Controls all individual components of the compiler and coordinates errors
if __FILE__ == $0
  # create the tokenizer
  t = Tokenizer.new ARGV[0]
  
  # pass the tokenizer to the parser
  p = Parser.new t

  # parse the input program into an AST
  ast = p.parse
  #ast.check()
  
  # print errors, if any
  PL0CompilerError.dump
  
  # print all symbols found in the program
  if SYMBOL
    puts "\nSymbolTable:\n"
    SymbolTable.instance.to_s
    puts "Size: #{SymbolTable.instance.size}"
  end
  
  # this IDE runs the application twice for some reason, stop it
  exit
end
