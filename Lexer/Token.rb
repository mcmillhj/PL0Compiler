#
# Token.rb
# Defines the characteristics of a Token object
#
# Hunter McMillen
# 2/7/2012
##################################################
require_relative 'TokenType.rb'

class Token
  #define getter/setter methods for these instance variables
  attr_reader   :type, :line_number, :text 
  attr_accessor :scope, :proc_name

  # Creates a new Token with an integer value of type
  # a line number of line
  # and a literal value of text
  def initialize(type, line, text, scope=nil, proc_name=nil)
    @type        = type
    @line_number = line
    @text        = text
    @scope       = scope
    @proc_name   = proc_name
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
    return "Text: '#{@text}', Type: '#{@type.name}', Location: line #{@line_number}" if @scope == nil and @proc_name == nil
    return "Text: '#{@text}', Type: '#{@type.name}', Location: line #{@line_number}, Scope: #{@scope}" if @scope != nil and @proc_name == nil
    if @proc_name != nil and @scope != nil
      return "Text: '#{@text}', Type: '#{@type.name}', Location: line #{@line_number}, Scope: #{@scope}, Procedure: #{@proc_name}"
    end
  end
end
