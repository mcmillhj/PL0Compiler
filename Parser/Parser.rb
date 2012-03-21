#
# Parser.rb
#
# Parses the syntax of the input file using the recursive descent method
# logs all errors and prints after parsing is completed
#
# author:  Hunter McMillen
# version: V1, 3/10/2012
######################################################################
require_relative '../Lexer/Tokenizer.rb'
require_relative '../Lexer/TokenType.rb'
require_relative '../Lexer/SymbolTable.rb'

class Parser
  # initializes fields of the Parser
  def initialize(tokenizer)
    @tokenizer    = tokenizer
    @symbol_table = SymbolTable.instance
    @sym          = Token.new("EMPTY", -1, "emptyString")
  end
  
  # Asks the tokenizer for the next token 
  # in the input file
  def next_token()
    @sym = @tokenizer.next_token()
  end
  
  # Skips input symbols until a symbol 
  # is found from which compilation may 
  # resume
  #
  # keys: a Set of strings containing all symbols 
  # from which compilation can resume
  def error(keys)
    $stderr.puts "Error #{@sym}"
    while not keys.include? @sym
      next_token()
    end
  end
  
  # Checks to see if the current symbol
  # is a key symbol
  # This check is done before all branches
  def check(keys)
    puts "#{keys.inspect}"
    if not (keys.include? @sym.text)
      error(keys)
    end
  end
  
  # starts the parsing process
  def parse
    program(Program.follow) 
  end
  
  # <program> -> <block> '.'
  def program(keys)
    next_token()
    block(keys | Set['.'])
    
    if @sym.type == TokenType.PERIOD_TOKEN
      next_token()
    else
      error(keys)
    end
  end
  
  #                 e
  # <block> -> <declaration> <statement>
  def block(keys)
    check(keys | Declaration.first | Statement.first)
    if Declaration.first.include? @sym.text
      declaration(keys | Block.follow)
    elsif Statement.first.include? @sym.text
      statement(keys | Block.follow)
    else
      error(keys | Block.follow)
    end
  end
  
  # MIGHT BE WRONG
  #                       e           e           e
  # <declaration> -> <const-decl> <var-decl> <proc-decl>
  def declaration(keys)
    const_decl(keys | Declaration.follow | VarDecl.first | ProcDecl.first)
    var_decl  (keys | Declaration.follow | ProcDecl.first)
    proc_decl (keys | Declaration.follow)
  end
  
  def statement(keys)
    check(keys | Statment.first)
    if @sym.type == TokenType.IDENT_TOKEN
      next_token() # grab a token
      if @sym.type == TokenType.ASSIGN_TOKEN # check for assign op
        next_token()
        expression(keys | Statement.follow)
      else
        error(keys | Statement.follow)
      end
    elsif @sym.type == TokenType.CALL_TOKEN
    elsif @sym.type == TokenType.BEGIN_TOKEN
    elsif @sym.type == TokenType.IF_TOKEN
    elsif @sym.type == TokenType.WHILE_TOKEN
    else
      error(keys | Statement.follow)
      
    end
  end
end
