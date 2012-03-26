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

PRINT = false

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
  def next_token()
    c = @infile.getc()
    token = nil

    while token == nil
      case c
      when /[a-zA-Z\$]/
        token = scan_identifier(c)
      when /[0-9]/
        token = scan_number(c)
      when /[\;\,\:\.\}\{\+\-\*\/\=\<\>]/
        token = scan_operator(c)
      when /[^\S\n]/
        #ignore spaces and tabs
        c = @infile.getc()
      when /\n/
        if PRINT
          puts  "Program line: #{@line_no}"
          puts  "The input statement is: #{$in_buffer.join(" ")}"
          print "The tokens are: #{$out_buffer.join(" ")}"
          puts  "#{TokenType::EOL_TOKEN.value}\n\n"
        end
        # reset the buffering
        $in_buffer.clear
        $out_buffer.clear
        # increment line number
        @line_no += 1
        token = Token.new(TokenType::EOL_TOKEN, @line_no, "EOL")
      when nil
        if PRINT
          puts  "Program line: #{@line_no}"
          puts  "The input statement is: #{$in_buffer.join(" ")}"
          print "The tokens are: #{$out_buffer.join(" ")}"
          print " #{TokenType::EOL_TOKEN.value}"
          puts  " * #{TokenType::EOF_TOKEN.value}\n\n"
        end
        
        token = Token.new(TokenType::EOF_TOKEN, @line_no, "EOF")
      else
        # warn user of invalid tokens
        TokenizerError.log("Line #{@line_no}: Invalid symbol '#{c}' found")
        c = @infile.getc()
      end
    end
    
    return token
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
      t = TokenType::IDENT_TOKEN
      token = Token.new(t, @line_no, id)
      # if this identifier isnt in the SymbolTable, insert it
      @symbol_table.insert(token, token.hash) if not @symbol_table.contains(token.text)
      $out_buffer.push("#{t.value} #{token.hash} *")
    else
      $out_buffer.push("#{reserved.value} *")
      token = Token.new(reserved, @line_no, id)
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

    t = TokenType::NUMERAL_TOKEN
    token = Token.new(t, @line_no, num)
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
    token = Token.new(t, @line_no, op)
    $in_buffer.push (op)
    $out_buffer.push ("#{t.value} *")
    return token
  end
end
