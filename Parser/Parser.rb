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
    if @sy.type == TokenType::EOF_TOKEN
      exit()
    end
    while @sy.type == TokenType::EOL_TOKEN
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
    
    if @sy.type == TokenType::IDENT_TOKEN
      test = "identifier"
    else
      test = @sy.text
    end
    
    if not keys.include? test
       error(keys)
    end
  end
  
  # starts the parsing process
  def parse
    program(Program.follow) 
  end
  
  # <program> -> <block> '.'
  def program(keys)
    puts "In program"
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
    puts "In block"
    declaration(keys | Block.follow | Statement.first)
    statement(keys | Block.follow)
  end
  
  #                       e           e           e
  # <declaration> -> <const-decl> <var-decl> <proc-decl>
  def declaration(keys)
    puts "In declaration"
    const_decl(keys | Declaration.follow | VarDecl.first | ProcDecl.first)
    var_decl  (keys | Declaration.follow | ProcDecl.first)
    proc_decl (keys | Declaration.follow)
  end
  
  # <statement> -> [ident] ':=' <expression>
  # <statement> -> 'call' [ident]
  # <statement> -> 'begin' <statement-list> 'end'
  # <statement> -> 'if' <condition> 'then' <statement>
  # <statement> -> 'while' <condition> 'do' <statement>
  # <statement> -> e
  def statement(keys)
    puts "In statement"
    check(keys | Statement.first | Statement.follow)
    if @sy.type == TokenType::IDENT_TOKEN
      next_token() # grab a token
      if @sy.type == TokenType::ASSIGN_TOKEN # check for assign op
        next_token()
        expression(keys | Statement.follow)
      else
        error(keys | Statement.follow)
      end
    elsif @sy.type == TokenType::CALL_TOKEN
      next_token()
      if @sy.type == TokenType::IDENT_TOKEN
        next_token()
      else
        error(keys | Statement.follow)
      end
    elsif @sy.type == TokenType::BEGIN_TOKEN
      next_token()
      statement_list(keys | Set['end'] | Statement.follow)
      if @sy.type == TokenType::END_TOKEN
        next_token()
      else
        error(keys | Statement.follow)  
      end
    elsif @sy.type == TokenType::IF_TOKEN
      next_token()
      condition(keys | Statement.follow | Set['then'])
      if @sy.type == TokenType::THEN_TOKEN
        next_token()
        statement(keys | Statement.follow)
      else
        error(keys | Statement.follow)
      end
    elsif @sy.type == TokenType::WHILE_TOKEN
      next_token()
      condition(keys | Set['do'] | Statement.follow)
      if @sy.type == TokenType::DO_TOKEN
        statement(keys | Statement.follow)
      else
        error(keys | Statement.follow | Statement.first)
      end
    end
  end
  
  # <statement-list> -> <statement> <statement-A>
  def statement_list(keys)
    puts "In statement_list"
    statement(keys   | StatementList.follow | StatementA.first)
    statement_a(keys | StatementList.follow)
  end
  
  def statement_a(keys)
    puts "In statement_a"
    if @sy.type == TokenType::SEMI_COL_TOKEN
      next_token()
      statement(keys | StatementA.follow | StatementA.first)
      statement_a(keys | StatementA.follow)
    end
  end
  
  # const-decl -> 'const' <const-list> ';'
  # const-decl -> e
  def const_decl(keys)
    puts "In const_decl"
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
  
  # <const-list> -> [ident] '=' [number] <const-A>
  def const_list(keys)
    puts "In const_list"
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
  
  # <const-A> -> ',' [ident] '=' [number] <const-A>
  # <const-A> -> e 
  def const_a(keys)
    puts "In const_list"
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
  
  # <var-decl> -> 'var' <ident-list> ';'
  # <var-decl> -> e 
  def var_decl(keys)
    puts "In var_decl"
    if @sy.type == TokenType::VAR_TOKEN
      next_token()
      ident_list(keys | Set[';'] | VarDecl.follow)
      if @sy.type == TokenType::SEMI_COL_TOKEN
        next_token()
      else
        error(keys | VarDecl.follow)
      end
    end
  end

  # <proc_decl> -> e <proc-A>
  def proc_decl(keys)
    puts "In proc_decl"
    proc_a(keys | ProcDecl.follow)
  end
  
  # <proc-A> -> 'procedure' [ident] ';' <block> ';' <proc-A>
  # <proc-A> -> e 
  def proc_a(keys)
    puts "In proc_a"
    if @sy.type == TokenType::PROCEDURE_TOKEN
      next_token()
      if @sy.type == TokenType::IDENT_TOKEN
        next_token()
        if @sy.type == TokenType::SEMI_COL_TOKEN
          next_token()
          block(keys | ProcA.follow)
          if @sy.type == TokenType::SEMI_COL_TOKEN
            next_token()
            proc_a(keys | ProcA.follow)
          else
            error(keys | ProcA.follow | ProcA.first)
          end
        else
          error(keys | ProcA.follow | Block.first)
        end
      else
        error(keys | ProcA.follow | Set[';'])
      end
    end
  end
  
  # <ident-list> -> [ident] <ident-A>
  def ident_list(keys)
    puts "In ident_list"
    if @sy.type == TokenType::IDENT_TOKEN
      next_token()
      ident_a(keys | IdentList.follow)
    else
      error(keys | IdentList.follow)  
    end
  end
  
  # <ident-A> -> ',' [ident] <ident-A>
  # <ident-A> -> e
  def ident_a(keys)
    puts "In ident_a"
    if @sy.type == TokenType::COMMA_TOKEN
      next_token()
      if @sy.type == TokenType::IDENT_TOKEN
        next_token()
        ident_a(keys | IdentA.follow)
      else
        error(keys | IdentA.follow)
      end
    end
  end
  
  # <condition> -> 'odd' <expression>
  # <condition> -> <expression> <relop> <expression>
  def condition(keys)
    check(keys | Condition.follow | Set['odd'] | Expression.first)
    
    if Set['odd'].include? @sy.text
      next_token()
      expression(keys | Condition.follow)      
    elsif Expression.first.include? @sy.text or Expression.first.include? "identifier"
      expression(keys | Condition.follow | Relop.first)      
      relop(keys | Condition.follow | Expression.first)     
      expression(keys | Condition.follow) 
    else
      error(keys | Condition.follow)
    end
  end
  
  # <expression> -> <term> <expression-A>
  # <expression> -> <add-subop> <term> <expression-A>
  def expression(keys)
    check(keys | Expression.follow | Term.first | AddSubOp.first)
    if Term.first.include? @sy.text or Term.first.include? "identifier"
      term(keys | Expression.follow | ExpressionA.first)
      expression_a(keys | Expression.follow)
    elsif AddSubOp.first.include? @sy.text
      add_sub_op(keys | Expression.follow | Term.first)
      term(keys | Expression.follow | ExpressionA.first)
      expression_a(keys | Expression.follow)
    else
      error(keys | Expression.follow)  
    end
  end
  
  # <expression-A> -> <add-subop> <term> <expression-A>
  # <expression-A> -> e
  def expression_a(keys)
    check(keys | ExpressionA.follow | AddSubOp.first | SetConstants::EMPTY_SET)
    if AddSubOp.first.include? @sy.text
      add_sub_op(keys | ExpressionA.follow | Term.first)
      term(keys | ExpressionA.follow | ExpressionA.first)
      expression_a(keys | ExpressionA.follow)
    end
  end
  
  # <term> -> <factor> <term-A>
  def term(keys)
    factor(keys | Term.follow | TermA.first)
    term_a(keys | Term.follow)
  end
  
  # <term-A> -> <mult-divop> <factor> <term-A>
  # <term-A> -> e
  def term_a(keys)
    check(keys | TermA.follow | MultDivOp.first | SetConstants::EMPTY_SET)
    if MultDivOp.first.include? @sy.text
      mult_div_op(keys | TermA.follow | Factor.first)
      factor(keys | TermA.follow | TermA.first)
      term_a(keys | TermA.follow)
    end
  end
  
  def factor(keys)
    check(keys | Factor.follow | Set['identifier','numeral','('])
    if @sy.type == TokenType::IDENT_TOKEN
      next_token()
    elsif @sy.type == TokenType::NUMERAL_TOKEN
      next_token()
    elsif @sy.type == TokenType::L_PAREN_TOKEN
      next_token()
      expression(keys | Factor.follow | Set['('])
      if @sy.type == TokenType::R_PAREN_TOKEN
        next_token()
      else
        error(keys | Factor.follow)
      end
    else
      error(keys | Factor.follow)
    end
  end
end
