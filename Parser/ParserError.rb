#
# ParserError.rb
#
# Forwards errors and warnings from the Parser 
# program to the compiler error log
######################################################################
require_relative '../PL0CompilerError.rb'

class ParserError < PL0CompilerError
  def self.warn(warn_string)
    parser_warn_string = "Parser: " + warn_string
    self.superclass.warn(parser_warn_string)
  end
  
  def self.log(error_string)
    self.superclass.log("Parser", error_string)
  end
end