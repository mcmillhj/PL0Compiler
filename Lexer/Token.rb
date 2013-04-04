#
# Token.rb
# Defines the characteristics of a Token object
#
# Hunter McMillen
# 2/7/2012
##################################################
require_relative 'TokenType.rb'

class Token
  attr_reader   :type, :line_number, :text     # only getter
  attr_accessor :scope, :func_name, :data_type # getter and setter

  # Creates a new Token that has a specific type, data_type, scope, and func_name
  def initialize(type, line, text, scope=nil, func_name=nil, data_type=nil)
    @type        = type
    @line_number = line
    @text        = text
    @scope       = scope
    @func_name   = func_name
    @data_type   = data_type
  end
  
  # uses two prime constants 17 and 37 to compute
  # this token index into the SymbolTable
  # adapted from Effective Java by Joshua Bloch pgs 48-49
  def hash
    p, q  = 17, 37
    p = q * p + @type.hash
    p = q * p + @text.hash
    p = q * p + @scope.hash
    p = q * p + @func_name.hash if @func_name # this field is only present for identifiers in non-global scope
    
    # bound the hash function by the TABLE_SIZE
    return (p % SymbolTable::TABLE_SIZE).to_i
  end

  # Prints a string representation of a Token
  def to_s
    return "Text: '#{@text}', TokenType: '#{@type.name}', Location: line #{@line_number}" if @scope == nil and @func_name == nil and @data_type == nil
    return "Text: '#{@text}', TokenType: '#{@type.name}', Location: line #{@line_number}, Scope: #{@scope}" if @scope and @func_name == nil and @data_type == nil
    if @func_name != nil and @scope != nil and @data_type != nil
      return "Text: '#{@text}', TokenType: '#{@type.name}', Type: '#{data_type}', Location: line #{@line_number}, Scope: #{@scope}, Function: #{@func_name}"
    elsif @data_type == nil 
      return "Text: '#{@text}', TokenType: '#{@type.name}', Location: line #{@line_number}, Scope: #{@scope}, Function: #{@func_name}"
    end
  end
end
