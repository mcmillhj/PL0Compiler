#
# Tokenizer.rb 
#
# Reads the source file a single character at a time until EOF.
# For each character read, some scanning operation will be performed
# (i.e. if a number is recognized; scan_number() would be called
#
# author:  Hunter McMillen
# version: V1, 2/6/2012
######################################################################
require_relative 'TokenizerError.rb'
require_relative 'TokenType.rb'
require_relative 'SymbolTable.rb'
require_relative 'Token.rb'

class Tokenizer
  $in_buffer  = [] # stores the current line of input from the source program
  $out_buffer = [] # stores the current line of output from the Tokenizer
  
  # Creates a new instance of a Tokenizer, pointed at an input file
  def initialize(filename)
    #open the source file for reading
    @infile = File.open(filename, "r")  
    
    # grab THE instance of the SymbolTable  
    @symbol_table = SymbolTable.instance
    
    #intialize the line and column numbers
    @line_no = 1
  end

  #classify each character, and call approriate scan methods
  def tokenize()
    @infile.each_char do |c|
        case c
        when /[a-zA-Z\$]/
          scan_identifier(c)
        when /[0-9]/
          scan_number(c)
        when /[\;\,\:\.\}\{\+\-\*\/\=\<\>]/
          scan_operator(c)
        when /[^\S\n]/ 
          #ignore spaces and tabs
        when /\n/
          puts  "Program line: #{@line_no}"
          puts  "The input statement is: #{$in_buffer.join(" ")}"
          print "The tokens are: #{$out_buffer.join(" ")}"
          puts " #{TokenType::RESERVED_WORDS["EOL"].value}\n\n"
          
          # reset the buffering
          $in_buffer.clear  
          $out_buffer.clear
          # increment line number, reset column number
          @line_no += 1
        else
          # warn user of invalid tokens
          TokenizerError.warn("Invalid symbol found, #{c}, ignoring...")
        end
    end
    
    # There are no more characters in the file, so print the 
    # last line of the program
    puts  "Program line: #{@line_no}"
    puts  "The input statement is: #{$in_buffer.join(" ")}"
    print "The tokens are: #{$out_buffer.join(" ")}"
    print " #{TokenType::RESERVED_WORDS["EOL"].value}"
    puts  " * #{TokenType::RESERVED_WORDS["EOF"].value}\n\n"
    
    puts @symbol_table
  end

  #Reads an identifier from the source program
  def scan_identifier(id)
    @infile.each_char do |c|
        if c =~ /[a-zA-Z0-9_]/
          id += c 
        else 
          # rewind the file 1 character so the lexer doesn't miss anything
          @infile.seek(-1, IO::SEEK_CUR)
          break # c is not part of the identifier, or possible an error
        end
    end
    
    #ensure that the identifier is <= 30 characters
    if id.length > 30
      id2 = id
      id = id.slice(0..29)
      #truncate the string to 30 characters
      TokenizerError.warn "Identifiers can only be 30 characters long, truncating #{id2} to #{id}"
    end
    
    if (reserved = TokenType::RESERVED_WORDS[id]) == nil
       t = TokenType::RESERVED_WORDS["identifier"]
       token = Token.new(t.type, @line_no, id)
       # if this identifier isnt in the SymbolTable, insert it
       @symbol_table.insert(token, token.hash) if not @symbol_table.lookup(token)
       $out_buffer.push("#{t.value} #{token.hash} *")
     else
       $out_buffer.push("#{reserved.value} *")
       token = Token.new(reserved.type, @line_no, id)
     end
    $in_buffer.push(id)
    return token
  end
  
  # Reads a number from the source program
  def scan_number(num)
    @infile.each_char do |c|
      if c =~ /[0-9]/
        num += c
      else
        # rewind the file 1 character so the lexer doesn't miss anything
        @infile.seek(-1, IO::SEEK_CUR)
        break #c is not part of an integer, or possibly an error
      end
    end
    
    #ensure that the number is <= 10 characters
    if num.length > 10
      num2 = num
      num = num.slice(0..9)
      #truncate the string to 30 characters
      TokenizerError.warn "Numerals can only be 10 characters long, truncating #{num2} to #{num}"
    end
    
    t = TokenType::RESERVED_WORDS["numeral"]
    token = Token.new(t.type, @line_no, num)
    $in_buffer.push(num)
    $out_buffer.push("#{t.value} #{num} *")
    return token
  end
  
  # Reads an operator from the source program
  def scan_operator(op)
    @infile.each_char do |c|
      if c =~ /[\=\>]/
        op += c
        break #the biggest operator is of length 2
      else
        # rewind the file 1 character so the lexer doesn't miss anything
        @infile.seek(-1, IO::SEEK_CUR)
        break # this is not a valid operator, or possibly an error
      end
    end
    
     t = TokenType::RESERVED_WORDS[op]
     token = Token.new(t.type, @line_no, op)
     $in_buffer.push (op)
     $out_buffer.push ("#{t.value} *")
     return token
  end
end
