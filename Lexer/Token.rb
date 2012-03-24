#
# Token.rb
# Defines the characteristics of a Token object
#
# Hunter McMillen
# 2/7/2012
##################################################
require_relative 'TokenType.rb'

class Token
  #define getter methods for these instance variables
  attr_reader :type, :line_number, :text

  # Creates a new Token with an integer value of type
  # a line number of line
  # and a literal value of text
  def initialize(type, line, text)
    @type        = type
    @line_number = line
    @text        = text
  end
  
  # uses two prime constants 17 and 37 to compute
  # this token index into the SymbolTable
  def hash
    p, q  = 17, 37
    p = q * p + @type.hash
    p = q * p + @text.hash
    
    # bound the hash function by the TABLE_SIZE
    return (p % SymbolTable::TABLE_SIZE).to_i
  end

  # Prints a string representation of a Token
  def to_s
    "Token '#{@text}' of Type: '#{@type.name}' at line: #{@line_number}"
  end
end
