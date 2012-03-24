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

DEBUG = false

class Parser
  # initializes fields of the Parser
  def initialize(tokenizer)
    @tokenizer    = tokenizer
    @symbol_table = SymbolTable.instance
    @sy           = Token.new("EMPTY", -1, "EMPTY")
  end
  
  # Asks the tokenizer for the next token 
  # in the input file
  def next_token()
    @sy = @tokenizer.next_token()
    # ignore EOL tokens as all productions would accept them
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
  def error(mesg, keys)
    $stderr.puts "Error: #{mesg}"
    while not keys.include? @sy.text
      next_token()
    end
  end

  # Checks to see if the current symbol
  # is a key symbol
  # This check is done before all branches
  def check(mesg, keys)
    #puts "Check: #{keys.inspect}"
    
    # special case, generalizes identifiers and numbers
    if @sy.type == TokenType::IDENT_TOKEN
      test = "identifier"
    elsif @sy.type == TokenType::NUMERAL_TOKEN
      test = "numeral"
    else
      test = @sy.text
    end
    
    if not keys.include? test
       error(mesg, keys)
    end
  end
  
  # starts the parsing process
  def parse
    program(SetConstants::EMPTY_SET) 
  end
  
  # <program> -> <block> '.'
  def program(keys)
    puts "Entering program '#{@sy.text}'" if DEBUG
    next_token()
    block(keys | Set['.'] | Program.follow)
    
    if @sy.type == TokenType::PERIOD_TOKEN
      next_token()
      if @sy.type == TokenType::EOF_TOKEN
        puts "Parse successful"
      end
    else
      error("Line #{@sy.line_number} expected a '.', but saw '#{@sy.text}'", keys | Program.follow)
    end
    puts "Leaving program" if DEBUG
  end
  
  #                 e
  # <block> -> <declaration> <statement>
  def block(keys)
    puts "Entering block ''#{@sy.text}''" if DEBUG
    declaration(keys | Block.follow | Statement.first)
    statement(keys | Block.follow)
    puts "Leaving block" if DEBUG
  end
  
  #                       e           e           e
  # <declaration> -> <const-decl> <var-decl> <proc-decl>
  def declaration(keys)
    puts "Entering declaration '#{@sy.text}'" if DEBUG
    const_decl(keys | Declaration.follow | VarDecl.first | ProcDecl.first)
    var_decl  (keys | Declaration.follow | ProcDecl.first)
    proc_decl (keys | Declaration.follow)
    puts "Leaving declaration" if DEBUG
  end
  
  # <statement> -> [ident] ':=' <expression>
  # <statement> -> 'call' [ident]
  # <statement> -> 'begin' <statement-list> 'end'
  # <statement> -> 'if' <condition> 'then' <statement>
  # <statement> -> 'while' <condition> 'do' <statement>
  # <statement> -> e
  def statement(keys)
    puts "Entering statement '#{@sy.text}'" if DEBUG
    check("Line #{@sy.line_number}: expecting #{Statement.first} but saw '#{@sy.text}'", 
          keys | Statement.first | Statement.follow)
    
    if @sy.type == TokenType::IDENT_TOKEN
      next_token() # grab a token
      if @sy.type == TokenType::ASSIGN_TOKEN # check for assign op
        next_token()
        expression(keys | Statement.follow)
      else
        error("Line #{@sy.line_number}: expected ':=' but saw '#{@sy.text}'", keys | Statement.follow)
      end
    elsif @sy.type == TokenType::CALL_TOKEN
      next_token()
      if @sy.type == TokenType::IDENT_TOKEN
        next_token()
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'", keys | Statement.follow)
      end
    elsif @sy.type == TokenType::BEGIN_TOKEN
      next_token()
      statement_list(keys | Set['end'] | Statement.follow)
      if @sy.type == TokenType::END_TOKEN
        next_token()
      else
        error("Line #{@sy.line_number}: expected 'end' but saw '#{@sy.text}'", keys | Statement.follow)  
      end
    elsif @sy.type == TokenType::IF_TOKEN
      next_token()
      condition(keys | Statement.follow | Set['then'])
      if @sy.type == TokenType::THEN_TOKEN
        next_token()
        statement(keys | Statement.follow)
      else
        error("Line #{@sy.line_number}: expected 'then' but saw '#{@sy.text}'",keys | Statement.follow)
      end
    elsif @sy.type == TokenType::WHILE_TOKEN
      next_token()
      condition(keys | Set['do'] | Statement.follow)
      if @sy.type == TokenType::DO_TOKEN
        next_token()
        statement(keys | Statement.follow)
      else
        error("Line #{@sy.line_number}: expected 'do' but saw '#{@sy.text}'",keys | Statement.follow | Statement.first)
      end
    end
    puts "Leaving statement" if DEBUG
  end
  
  # <statement-list> -> <statement> <statement-A>
  def statement_list(keys)
    puts "Entering statement_list '#{@sy.text}'" if DEBUG
    statement(keys   | StatementList.follow | StatementA.first)
    statement_a(keys | StatementList.follow)
    puts "Leaving statement_list" if DEBUG
  end
  
  def statement_a(keys)
    puts "Entering statement_a '#{@sy.text}'" if DEBUG
    if @sy.type == TokenType::SEMI_COL_TOKEN
      next_token()
      statement(keys | StatementA.follow | StatementA.first)
      statement_a(keys | StatementA.follow)
    end
    puts "Leaving statment_a" if DEBUG
  end
  
  # const-decl -> 'const' <const-list> ';'
  # const-decl -> e
  def const_decl(keys)
    puts "Entering const_decl '#{@sy.text}'" if DEBUG
    if @sy.type == TokenType::CONST_TOKEN
      next_token()
      const_list(keys | ConstDecl.follow)
      if @sy.type == TokenType::SEMI_COL_TOKEN
        next_token();
      else
        error("Line #{@sy.line_number}: expected ';' but saw '#{@sy.text}'",keys | ConstDecl.follow)
      end
    end
    puts "Leaving const_decl" if DEBUG
  end
  
  # <const-list> -> [ident] '=' [number] <const-A>
  def const_list(keys)
    puts "Entering const_list '#{@sy.text}'" if DEBUG
    if @sy.type == TokenType::IDENT_TOKEN
      next_token()
      if @sy.type == TokenType::EQUALS_TOKEN
        next_token()
        if @sy.type == TokenType::NUMERAL_TOKEN
          next_token()
          const_a(keys | ConstList.follow)
        else
          error("Line #{@sy.line_number}: expected 'numeral' but saw '#{@sy.text}'",keys | ConstA.first)
        end
      else
        error("Line #{@sy.line_number}: expected '=' but saw '#{@sy.text}'",keys | ConstA.first)
      end
    else
      error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'",keys | ConstA.first)
    end 
    puts "Leaving const_list" if DEBUG
  end
  
  # <const-A> -> ',' [ident] '=' [number] <const-A>
  # <const-A> -> e 
  def const_a(keys)
    puts "Entering const_a '#{@sy.text}'" if DEBUG
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
            error("Line #{@sy.line_number}: expected 'numeral' but saw '#{@sy.text}'",keys | ConstA.follow)
          end
        else
          error("Line #{@sy.line_number}: expected '=' but saw '#{@sy.text}'",keys | ConstA.follow)
        end
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'",keys | ConstA.follow)
      end
    end
    puts "Leaving const_a" if DEBUG
  end
  
  # <var-decl> -> 'var' <ident-list> ';'
  # <var-decl> -> e 
  def var_decl(keys)
    puts "Entering var_decl '#{@sy.text}'" if DEBUG
    if @sy.type == TokenType::VAR_TOKEN
      next_token()
      ident_list(keys | Set[';'] | VarDecl.follow)
      if @sy.type == TokenType::SEMI_COL_TOKEN
        next_token()
      else
        error("Line #{@sy.line_number}: expected ';' but saw '#{@sy.text}'",keys | VarDecl.follow)
      end
    end
    puts "Leaving var_decl" if DEBUG
  end

  # <proc_decl> -> e <proc-A>
  def proc_decl(keys)
    puts "Entering proc_decl '#{@sy.text}'" if DEBUG
    proc_a(keys | ProcDecl.follow)
    puts "Leaving proc_decl" if DEBUG
  end
  
  # <proc-A> -> 'procedure' [ident] ';' <block> ';' <proc-A>
  # <proc-A> -> e 
  def proc_a(keys)
    puts "Entering proc_a '#{@sy.text}'" if DEBUG
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
            error("Line #{@sy.line_number}: expected ';' but saw '#{@sy.text}'",keys | ProcA.follow | ProcA.first)
          end
        else
          error("Line #{@sy.line_number}: expected ';' but saw '#{@sy.text}'",keys | ProcA.follow | Block.first)
        end
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'",keys | ProcA.follow | Set[';'])
      end
    end
    puts "Leaving proc_a" if DEBUG
  end
  
  # <ident-list> -> [ident] <ident-A>
  def ident_list(keys)
    puts "Entering ident_list '#{@sy.text}'" if DEBUG
    if @sy.type == TokenType::IDENT_TOKEN
      next_token()
      ident_a(keys | IdentList.follow)
    else
      error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'",keys | IdentList.follow)  
    end
    puts "Leaving ident_list" if DEBUG
  end
  
  # <ident-A> -> ',' [ident] <ident-A>
  # <ident-A> -> e
  def ident_a(keys)
    puts "Entering ident_a '#{@sy.text}'" if DEBUG
    if @sy.type == TokenType::COMMA_TOKEN
      next_token()
      if @sy.type == TokenType::IDENT_TOKEN
        next_token()
        ident_a(keys | IdentA.follow)
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'",keys | IdentA.follow)
      end
    end
    puts "Leaving ident_a" if DEBUG
  end
  
  # <condition> -> 'odd' <expression>
  # <condition> -> <expression> <relop> <expression>
  def condition(keys)
    puts "Entering condition '#{@sy.text}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{Condition.first.inspect} but saw '#{@sy.text}'",
          keys | Condition.follow | Set['odd'] | Expression.first)
    
    if Set['odd'].include? @sy.text
      next_token()
      expression(keys | Condition.follow)      
    elsif Expression.first.include? @sy.text or Expression.first.include? "identifier"
      expression(keys | Condition.follow | Relop.first)      
      relop(keys | Condition.follow | Expression.first)     
      expression(keys | Condition.follow) 
    else
      error("Line #{@sy.line_number}: expected #{Condition.first.inspect} but saw '#{@sy.text}'",
            keys | Condition.follow)
    end
    puts "Leaving condition" if DEBUG
  end
  
  # <expression> -> <term> <expression-A>
  # <expression> -> <add-subop> <term> <expression-A>
  def expression(keys)
    puts "Entering expression '#{@sy.text}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{Expression.first.inspect} but saw '#{@sy.text}'",
          keys | Expression.follow | Term.first | AddSubOp.first)
          
    if Term.first.include? @sy.text or Term.first.include? "identifier"
      term(keys | Expression.follow | ExpressionA.first)
      expression_a(keys | Expression.follow)
    elsif AddSubOp.first.include? @sy.text
      add_sub_op(keys | Expression.follow | Term.first)
      term(keys | Expression.follow | ExpressionA.first)
      expression_a(keys | Expression.follow)
    else
      error("Line #{@sy.line_number}: expected #{Expression.first.inspect} but saw '#{@sy.text}'",
            keys | Expression.follow)  
    end
    puts "Leaving expression" if DEBUG
  end
  
  # <expression-A> -> <add-subop> <term> <expression-A>
  # <expression-A> -> e
  def expression_a(keys)
    puts "Entering expression_a '#{@sy.text}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{ExpressionA.first.inspect} but saw '#{@sy.text}'",
          keys | ExpressionA.follow | AddSubOp.first | SetConstants::EMPTY_SET)
    if AddSubOp.first.include? @sy.text
      add_sub_op(keys | ExpressionA.follow | Term.first)
      term(keys | ExpressionA.follow | ExpressionA.first)
      expression_a(keys | ExpressionA.follow)
    end
    puts "Leaving expression_a" if DEBUG
  end
  
  # <term> -> <factor> <term-A>
  def term(keys)
    puts "Entering term '#{@sy.text}'" if DEBUG
    factor(keys | Term.follow | TermA.first)
    term_a(keys | Term.follow)
    puts "Leaving term" if DEBUG
  end
  
  # <term-A> -> <mult-divop> <factor> <term-A>
  # <term-A> -> e
  def term_a(keys)
    puts "Entering term_a '#{@sy.text}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{TermA.first.inspect} but saw '#{@sy.text}'", 
          keys | TermA.follow | MultDivOp.first | SetConstants::EMPTY_SET)
    if MultDivOp.first.include? @sy.text
      mult_div_op(keys | TermA.follow | Factor.first)
      factor(keys | TermA.follow | TermA.first)
      term_a(keys | TermA.follow)
    end
    puts "Leaving term_a" if DEBUG
  end
  
  # <factor> -> [ident]
  # <factor> -> [number]
  # <factor> -> '(' <expression> ')'
  def factor(keys)
    puts "Entering factor '#{@sy.text}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{Factor.first.inspect} but saw '#{@sy.text}'",
          keys | Factor.follow | Set['identifier','numeral','('])
    if @sy.type == TokenType::IDENT_TOKEN or @sy.type == TokenType::NUMERAL_TOKEN
      next_token()
    elsif @sy.type == TokenType::L_PAREN_TOKEN
      next_token()
      expression(keys | Factor.follow | Set['('])
      if @sy.type == TokenType::R_PAREN_TOKEN
        next_token()
      else
        error("Line #{@sy.line_number}: expected ')' but saw '#{@sy.text}'",keys | Factor.follow)
      end
    else
      error("Line #{@sy.line_number}: expected 'identifier' or 'numeral' but saw '#{@sy.text}'",
            keys | Factor.follow)
    end
    puts "Leaving factor" if DEBUG
  end
  
  # <add-subop> -> '+'
  # <add-subop> -> '-'
  def add_sub_op(keys)
    puts "Entering add_sub_op '#{@sy.text}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{AddSubOp.first.inspect} but saw '#{@sy.text}'",
          keys | AddSubOp.follow | AddSubOp.first)
    if @sy.type == TokenType::PLUS_TOKEN or @sy.type == TokenType::MINUS_TOKEN
      next_token()
    else
      error("Line #{@sy.line_number}: expected #{AddSubOp.first.inspect} but saw '#{@sy.text}'",
            keys | AddSubOp.follow)
    end
    puts "Leaving add_sub_op" if DEBUG
  end
  
  # <mult-divop> -> '*' | '\'
  def mult_div_op(keys)
    puts "Entering mult_div_op" if DEBUG
    check("Line #{@sy.line_number}: expected #{MultDivOp.first.inspect} but saw '#{@sy.text}'",
          keys | MultDivOp.follow | MultDivOp.first)
    if @sy.type == TokenType::MULT_TOKEN or @sy.type == TokenType::F_SLASH_TOKEN
      next_token()
    else
      error("Line #{@sy.line_number}: expected #{MultDivOp.first.inspect} but saw '#{@sy.text}'", 
            keys | MultDivOp.follow)
    end
    puts "Leaving mult_div_op" if DEBUG
  end
  
  # <relop> -> '=' | '<>' | '<' | '>' | '<=' | '>='
  def relop(keys)
    puts "Entering relop '#{@sy.text}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{Relop.first.inspect} but saw '#{@sy.text}'",
          keys | Relop.follow | Relop.first)
    if @sy.type == TokenType::EQUALS_TOKEN      or @sy.type == TokenType::RELOP_NEQ_TOKEN or
       @sy.type == TokenType::RELOP_LT_TOKEN    or @sy.type == TokenType::RELOP_GT_TOKEN  or
       @sy.type == TokenType::RELOP_LT_EQ_TOKEN or @sy.type == TokenType::RELOP_GT_EQ_TOKEN 
       next_token()
    else
      error("Line #{@sy.line_number}: expected #{Relop.first.inspect} but saw '#{@sy.text}'",
            keys | Relop.follow)
    end
    puts "Leaving relop" if DEBUG
  end
end
