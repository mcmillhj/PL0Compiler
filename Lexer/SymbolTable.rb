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
  def insert token
    insert_internal(token, token.hash)
  end
  
  def update(token, new_token)
    update_internal(token, token.hash, new_token)
  end
  
  def update_internal(token, index, new_token)
    @symbol_table[index].each do |v|
      if v == token
        v.scope      = new_token.scope      if new_token.scope  
        v.data_type  = new_token.data_type  if new_token.data_type
        v.ret_type   = new_token.ret_type   if new_token.ret_type
        v.parameters = new_token.parameters if new_token.parameters
        v.local_vars = new_token.local_vars if new_token.local_vars
      end
    end
  end
  
  # Inserts an element (identifier) into the SymbolTable
  def insert_internal(token, index)
    @symbol_table[index] << token
  end


  def lookup token
    lookup_internal(token.text, token.scope)
  end
  
  # Searches the SymbolTable for a given token
  # returns the token if found, otherwise returns nil
  def lookup_internal(name, scope)
    @symbol_table.each_pair do |k,v|
      v.each do |entry| # v is an array
        return entry if entry.text == name and entry.scope == scope
      end
    end

    return nil
  end

  # Returns true if name is in the symbol table
  # false otherwise
  def contains token 
    return lookup_internal(token.text, token.scope) != nil
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
    table = ''
    @symbol_table.each_pair do |k,v|
      table += "\n#{k}\t#{v}"
    end
    table += "\n\n"
    table
  end
end
