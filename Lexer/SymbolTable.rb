#
# SymbolTable.rb
# Table that stores all user defined identifiers
# There is only a single instance of the SymbolTable class
# for use by the entire compiler
#
# Hunter McMillen
# 2/7/2012
#################################################################
require 'singleton'
require_relative 'TokenType.rb'
require_relative 'Token.rb'
require_relative '../PL0Utils.rb'
require_relative 'SymbolTableError.rb'

class SymbolTable
  include Singleton

  MAX_SYMBOLS  = 10000
  DISPLACEMENT = PL0Utils.find_displacement(MAX_SYMBOLS)
  TABLE_SIZE   = MAX_SYMBOLS + (MAX_SYMBOLS * 0.1) + DISPLACEMENT
  
  # Constructs a single instance of a SymbolTable to be used by the whole compiler
  def initialize
    # Create a hash table to hold the symbol table, each key will be the hash of an object
    # each value will be the object(s) tbat hashed to that index
    @symbol_table = Hash.new {|h,k| h[k] = []}
  end

  # insert a token into the SymbolTable
  def insert(token)
    insert_internal(token, token.hash)
  end
  
  # Inserts an element (identifier) into the SymbolTable
  def insert_internal(token, index)
    @symbol_table[index] << token
  end

  # Searches the SymbolTable for a given token
  # returns the token if found, otherwise returns nil
  def lookup(name, scope, func_name)
    @symbol_table.each_pair do |k,v|
      v.each do |entry| # v is an array
        return entry if entry.text == name and entry.scope == scope and entry.func_name == func_name
      end
    end

    return nil
  end

  # Returns true if name is in the symbol table
  # false otherwise
  def contains(token)
    return lookup(token.text, token.scope, token.func_name) != nil
  end

  # counts the number of entries in the symbol table
  def size
    entries = 0

    @symbol_table.each_pair do |k,v|
      entries += v.length
    end

    return entries
  end

  # prints the SymbolTable to STDOUT
  def print
    puts to_s
  end
  
  # Prints a list of all elements currently in the SymbolTable
  def to_s
    @symbol_table.each_pair do |k,v|
      puts "index: #{k}\tvalue: #{v}"
    end
  end
end
