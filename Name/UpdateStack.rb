#
# UpdateStack.rb
#
# holds data about what identifiers can be seen
# in the current context
###############################################
require_relative '../Lexer/Token.rb'

# scope constants for identifiers
EXTERNAL = 'external'
INTERNAL = 'internal'

class UpdateStack
  def initialize
    @array = []
  end

  def push(val)
    @array.push val
  end

  def pop 
    @array.pop
  end
  
  def clear
    @array.clear
  end
  
  # search the stack for a token
  # return true if found, false otherwise
  def search(token)
    a = Array.new
    found = false
    # search until you find the current scope level
    begin
      var = pop
      (found = true if var.text == token.text) if var.kind_of? Token
      a.push var
    end until @array.empty? or found
    
    begin 
      @array.push a.pop
    end until a.empty?
    
    return found
  end
  
  def pop_level
    # pop elements until you remove the current scope
    begin
      var = pop
    end until var.kind_of? String
  end
  
  def print
    a = Array.new
    
    # search until you find the current scope level
    begin
      var = pop
      a.push var
      puts var.text if var.kind_of? Token
      puts var if var.kind_of? String
    end until @array.empty?
    puts "----------"
    begin 
      @array.push a.pop
    end until a.empty?
    
  end
  
  def get_current_scope
    a = Array.new
    
    # search until you find the current scope level
    begin
      var = pop
      a.push var
    end until var.kind_of? String
    
    # replace popped elements
    begin 
      @array.push a.pop
    end until a.empty?
    
    return var
  end
end
