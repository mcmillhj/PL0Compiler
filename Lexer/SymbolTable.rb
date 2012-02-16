#
# SymbolTable.rb
# Table that stores all user defined identifiers
# There is only a single instance of the SymbolTable class
# for use by the entire compiler
#
# Hunter McMillen
# 2/7/2012
#################################################################
require 'pp'
require 'singleton'

require_relative 'TokenType.rb'
require_relative 'Token.rb'
require_relative 'PL0Utils.rb'
require_relative 'SymbolTableError.rb'

class SymbolTable
  include Singleton

  MAX_SYMBOLS  = 500
  DISPLACEMENT = PL0Utils.find_displacement(MAX_SYMBOLS)
  TABLE_SIZE   = MAX_SYMBOLS + (MAX_SYMBOLS * 0.1) + DISPLACEMENT
  
  # Constructs a single instance of a SymbolTable to be used by the whole compiler
  def initialize()
    # Create a new array of size TABLE_SIZE with room for 10 overflow areas.
    @symbol_table = Hash.new {|h,k| h[k] = []}
  end

  # Inserts an element (identifier) into the SymbolTable
  def insert(element, index)
    @symbol_table[index] << element
  end
  
  # Searches the SymbolTable for a given token
  def lookup(token)
    index = token.hash
    text  = token.text
    
    # grab the array of entries for this index
    entries = @symbol_table[index]
 
    entries.each do |e|
      return true if e.text == text
    end
    
    return false
  end

  # Prints a list of all elements currently in the SymbolTable
  def to_s
    @symbol_table.each_pair do |k,v|
      puts "index: #{k} value: #{v}"
    end
  end
end
