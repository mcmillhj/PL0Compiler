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
  attr_accessor :scope, :data_type, :ret_type,
                 :params, :vars, :length
  
  # Creates a new Token that has a specific type, data_type, scope, and func_name
  def initialize(type, line, text, scope=nil, data_type=nil, ret_type=nil, params=[], vars=[], length=0)
    @type        = type
    @line_number = line
    @text        = text
    @scope       = scope
    @data_type   = data_type
    @ret_type    = ret_type
    @param       = params
    @vars        = vars
    @length      = length
  end
  
  # uses two prime constants 17 and 37 to compute
  # this token index into the SymbolTable
  # adapted from Effective Java by Joshua Bloch pgs 48-49
  def hash
    p, q  = 17, 37
    p = q * p + @type.hash
    p = q * p + @text.hash
    p = q * p + @scope.hash 
    
    # bound the hash function by the TABLE_SIZE
    return (p % SymbolTable::TABLE_SIZE).to_i
  end
 
  # Prints a string representation of a Token
  def to_s
    if @ret_type
      return "#{@text}: #{@type.name}, #{@data_type}, ##{@line_number}, scope: #{@scope}, return_type: #{@ret_type}, parameters: #{@params}, variables: #{@vars}"
    else
      return "#{@text}: TokenType: '#{@type.name}', Type: '#{@data_type}', Location: line #{@line_number}, Scope: #{@scope}"
    end

  end
end
