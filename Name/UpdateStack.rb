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
  
  # initializes the array for the stack implementation
  def initialize
    @array = []
  end

  # pushs a values onto the stack
  def push(val)
    @array.push val
  end

  # takes a value off the top of the stack
  def pop 
    @array.pop
  end
  
  # empties the stack
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
      var = pop # pop a token
      if var.kind_of? Token
         found = true if var.text == token.text
      else
         found = true if var == token.text
      end
      
      a.push var # push value into temp stack
    end until @array.empty? or found
    
    # replace all values popped in the search
    begin 
      @array.push a.pop
    end until a.empty?
    
    return found
  end
  
  # removes the most current scope level
  def pop_level
    # pop elements until you remove the current scope
    begin
      var = pop
    end until var.kind_of? String
    
    # push the proc name back on
    push(var)
  end
  
  # prints the stack
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
  
  # gets the most current scope level
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
