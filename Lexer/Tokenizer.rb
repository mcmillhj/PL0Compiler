#
# Tokenizer.rb
#
# Reads the source file a single character at a time until EOF.
# For each character read, some scanning operation will be performed
# (i.e. if a number is recognized; scan_number would be called
#
# author:  Hunter McMillen
# version: V1, 2/6/2012
######################################################################
require_relative 'TokenizerError.rb'
require_relative 'TokenType.rb'
require_relative 'SymbolTable.rb'
require_relative 'Token.rb'
class Tokenizer
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
  def next_token
    c     = @infile.getc # read the first character of the source file
    token = nil

    while token == nil
      case c
      when /[a-zA-Z]/
        token = scan_identifier(c)
      when /[0-9]/
        token = scan_number(c)
      when /[\.\;\,\:\[\]\}\{\+\-\*\/\=\<\>\(\)\&\|\!\#]/
        token = scan_operator(c)
      when /\%/
        # this is a comment, skip this line
        while (temp = @infile.getc).ord != 10
        # do nothing
        end

        # move to the next character
        c = @infile.getc

        # increment the line # to reflect the skipped comment line
        @line_no += 1
      when /[^\S\n]/ # ignore spaces and tabs
        c = @infile.getc
      when /\n/
        # increment line number
        @line_no += 1

        # emit an EOL token
        token = Token.new(TokenType::EOL_TOKEN, @line_no, "EOL")
      when nil
        # reached the end of the source program
        # emit an EOF token
        token = Token.new(TokenType::EOF_TOKEN, @line_no, "EOF")
      else
      # encountered a symbol that is not in the language
      TokenizerError.log("Line #{@line_no}: Invalid symbol '#{c}' found")
      c = @infile.getc
      end
    end

    return token
  end

  # Reads an identifier from the source program
  # one character at a time
  # If a symbol is encountered that is not part of an identifier
  # the scanner rewinds itself one character and returns
  def scan_identifier(id)
    @infile.each_char do |c|
      if c =~ /[a-zA-Z0-9_]\??/
      id += c
      else
      # rewind the file 1 character so the lexer doesn't miss anything
        @infile.seek(-1, IO::SEEK_CUR)
      break # c is not part of the identifier, or possible an error
      end
    end

    if (reserved = TokenType::RESERVED_WORDS[id]) == nil
      t = TokenType::IDENT_TOKEN
      token = Token.new(t, @line_no, id)
    # if this identifier isnt in the SymbolTable, insert it
    else
      token = Token.new(reserved, @line_no, id)
    end

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

    t = TokenType::NUMERAL_TOKEN
    token = Token.new(t, @line_no, num)

    return token
  end

  # Reads an operator from the source program
  def scan_operator(op)
    @infile.each_char do |c|
      if c =~ /[\=\>\.\&\|]/ and op =~/[\-\=\<\>\!\.\&\|]/
      op += c
      break # the biggest operator is of length 2
      else
      # rewind the file 1 character so the lexer doesn't miss anything
        @infile.seek(-1, IO::SEEK_CUR)
      break # this is not a valid operator, or possibly an error
      end
    end

    t = TokenType::RESERVED_WORDS[op]
    if t.nil?
      # encountered a symbol that is not in the language
      TokenizerError.log("Line #{@line_no}: Invalid operator '#{op}' found")
    end
    token = Token.new(t, @line_no, op)

    return token
  end
end
