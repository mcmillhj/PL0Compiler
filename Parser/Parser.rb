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
    @sy          = Token.new("EMPTY", -1, "emptyString")
  end
  
  # Asks the tokenizer for the next token 
  # in the input file
  def next_token()
    @sy = @tokenizer.next_token()
    puts "#{@sy}"
    while @sy == TokenType::EOL_TOKEN
      @sy = @tokenizer.next_token()
    end
  end
  
  # Skips input symbols until a symbol 
  # is found from which compilation may 
  # resume
  #
  # keys: a Set of strings containing all symbols 
  # from which compilation can resume
  def error(keys)
    $stderr.puts "Error #{@sy}"
    while not keys.include? @sy
      next_token()
    end
  end
  
  # Checks to see if the current symbol
  # is a key symbol
  # This check is done before all branches
  def check(keys)
    puts "Check: #{keys.inspect}"
    if not (keys.include? @sy.text)
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
    
    if @sy == TokenType::PERIOD_TOKEN
      next_token()
      if @sy == TokenType::EOF_TOKEN
        puts "Parse successful"
      end
    else
      error(keys)
    end
  end
  
  #                 e
  # <block> -> <declaration> <statement>
  def block(keys)
    declaration(keys | Block.follow | Statement.first)
    statement(keys | Block.follow)
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
    check(keys | Statement.first)
    if @sy.type == TokenType::IDENT_TOKEN
      next_token() # grab a token
      if @sy.type == TokenType::ASSIGN_TOKEN # check for assign op
        next_token()
        expression(keys | Statement.follow)
      else
        error(keys | Statement.follow)
      end
    elsif @sy.type == TokenType::CALL_TOKEN
      #this
    elsif @sy.type == TokenType::BEGIN_TOKEN
      #this
    elsif @sy.type == TokenType::IF_TOKEN
      #this
    elsif @sy.type == TokenType::WHILE_TOKEN
      #this
    else
      error(keys | Statement.follow)
    end
  end
  
  # const-decl -> 'const' <const-list> ';'
  # const-decl -> e
  def const_decl(keys)
    if @sy.type == TokenType::CONST_TOKEN
      next_token()
      const_list(keys | ConstDecl.follow)
      if @sy.type == TokenType::SEMI_COL_TOKEN
        next_token();
      else
        error(keys | ConstDecl.follow)
      end
    end
  end
  
  def const_list(keys)
    if @sy.type == TokenType::IDENT_TOKEN
      next_token()
      if @sy.type == TokenType::EQUALS_TOKEN
        next_token()
        if @sy.type == TokenType::NUMERAL_TOKEN
          next_token()
          const_a(keys | ConstList.follow)
        else
          error(keys | ConstA.first)
        end
      else
        error(keys | ConstA.first)
      end
    else
      error(keys | ConstA.first)
    end 
  end
  
  def const_a(keys)
     if @sy.type == TokenType::COMMA_TOKEN
      next_token()
      if @sy.type == TokenType::IDENT_TOKEN
        next_token()
        if @sy.type == TokenType::EQUALS_TOKEN
          next_token()
          if @sy.type == TokenType::NUMERAL_TOKEN
            next_token()
            const_a(keys | ConstA.follow)
          else
            error(keys | ConstA.follow)
          end
        else
          error(keys | ConstA.follow)
        end
      else
        error(keys | ConstA.follow)
      end
    end
  end
  
  def var_decl(keys)
    
  end

  def proc_decl(keys)
    
  end
end
