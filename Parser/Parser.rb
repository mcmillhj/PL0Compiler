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
require_relative '../Name/UpdateStack.rb'
require_relative '../Name/NamingError.rb'
require_relative 'ParserError.rb'
Dir[File.dirname(__FILE__) + '../SyntaxTree/*.rb'].each {|file| require_relative file}


# prints out entering/leaving statements
DEBUG = false

class Parser
  include Sets
  
  # initializes fields of the Parser
  def initialize(tokenizer)  
    @tokenizer     = tokenizer
    @symbol_table  = SymbolTable.instance
    @sy            = Token.new("EMPTY", -1, "EMPTY")
    @stack         = UpdateStack.new
    @current_level = 'global'
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
  
  # checks to see if an identifier is valid in the current scope
  def ident_check(sym)
    valid = @stack.search sym
    NamingError.log("Line #{sym.line_number}: No identifier '#{sym.text}' in current scope '#{@current_level}'") if not valid
  end
  
  # Skips input symbols until a symbol 
  # is found from which compilation may 
  # resume
  #
  # keys: a Set of strings containing all symbols 
  # from which compilation can resume
  def error(mesg, keys)
    ParserError.log(mesg)
    while not keys.include? @sy.text
      next_token()
    end
  end

  # Checks to see if the current symbol
  # is a key symbol
  # This check is done before all branches
  def check(mesg, keys)    
    # special case, generalizes identifiers and numbers
    if @sy.type == TokenType::IDENT_TOKEN
      test = "identifier"
    elsif @sy.type == TokenType::NUMERAL_TOKEN
      test = "numeral"
    elsif @sy.type == TokenType::STR_LITERAL_TOKEN
      test = "string_literal"
    else
      test = @sy.text
    end
    
    if not keys.include? test
       error(mesg, keys)
    end
  end
  
  # returns an AST to the main program
  def parse
    @stack.push @current_level
    program_node = program(Sets::EMPTY_SET) 
    
    return SyntaxTree.new(program_node)
  end
  
  # <program> -> <block> '.'
  def program(keys)
    puts "Entering program '#{@sy.text}'" if DEBUG
    next_token()
    block_node = block(keys | Set['.'] | Program.follow)
    
    if @sy.type == TokenType::PERIOD_TOKEN
      next_token()
      if @sy.type == TokenType::EOF_TOKEN
      end
    else
      error("Line #{@sy.line_number} expected a '.', but saw '#{@sy.text}'", keys | Program.follow)
    end
    puts "Leaving program '#{@sy.text}'" if DEBUG
    
    return ProgramNode.new(block_node)
  end
  
  #                 e
  # <block> -> <declaration> <statement>
  def block(keys)
    puts "Entering block '#{@sy.text}'" if DEBUG
    decl_node  = declaration(keys | Block.follow | Statement.first)
    state_node = statement(keys | Block.follow)
    puts "Leaving block '#{@sy.text}'" if DEBUG
    
    return BlockNode.new(decl_node, state_node) unless decl_node.nil? and state_node.nil?
    return BlockNode.new(decl_node, nil)        unless decl_node.nil?
    return BlockNode.new(nil, state_node)       unless state_node.nil?
  end
  
  #                       e           e           e
  # <declaration> -> <const-decl> <var-decl> <proc-decl>
  def declaration(keys)
    puts "Entering declaration '#{@sy.text}'" if DEBUG
    const_decl_node = const_decl(keys | Declaration.follow | VarDecl.first | ProcDecl.first)
    var_decl_node   = var_decl(keys | Declaration.follow | ProcDecl.first)
    proc_decl_node  = proc_decl(keys | Declaration.follow)
    puts "Leaving declaration '#{@sy.text}" if DEBUG
    
    return DeclarationNode.new(const_decl_node, var_decl_node, proc_decl_node)
  end
  
  def type(keys)
    type = nil 
    puts "Entering type '#{@sy.text}'" if DEBUG
    if Type.first.include? @sy.text
      type = @sy.text
      next_token()
    else
      error("Invalid type #{@sy.text}", keys | Type.follow)
    end   
    puts "Leaving type '#{@sy.text}'" if DEBUG
    
    return TypeNode.new(type)
  end
  
  # TODO update documentation 
  def statement(keys)
    statement_node = nil
     
    puts "Entering statement '#{@sy.text}'" if DEBUG
    check("Line #{@sy.line_number}: expecting #{Statement.first.to_a} but saw '#{@sy.text}'", 
          keys | Statement.first | Statement.follow)
    
    if @sy.type == TokenType::IDENT_TOKEN
      statement_node = assignment_statement(keys | Statement.follow)
    elsif @sy.type == TokenType::CALL_TOKEN
      next_token() # grab the next token
      statement_node = call_statement(keys | Statement.follow)
    elsif @sy.type == TokenType::BEGIN_TOKEN
      next_token() # grab the next token
      statement_node = begin_statement(keys | Statement.follow)
    elsif @sy.type == TokenType::IF_TOKEN
      next_token() # grab the next token
      statement_node = if_statement(keys | Statement.follow)
    elsif @sy.type == TokenType::WHILE_TOKEN
      next_token()
      statement_node = while_statement(keys | Statement.follow)
    elsif @sy.type == TokenType::PRINT_TOKEN
      next_token();
      statement_node = print_statement(keys | Statement.follow)
    elsif @sy.type == TokenType::READ_TOKEN
      next_token()
      statement_node = read_statement(keys | Statement.follow)
    end
    puts "Leaving statement '#{@sy.text}'" if DEBUG
    
    return StatementNode.new(statement_node) unless statement_node.nil?
  end
  
  # TODO docs
  def assignment_statement(keys)
    puts "Entering assignment_statement '#{@sy.text}'" if DEBUG
    id = nil
    expr_node = nil
      
    ident_check(@sy)
    id = @sy.text
    next_token() # grab a token
    if @sy.type == TokenType::ASSIGN_TOKEN # check for assign op
      next_token()
      expr_node = expression(keys | Statement.follow)
    else
      error("Line #{@sy.line_number}: expected ':=' but saw '#{@sy.text}'", keys | Statement.follow)
    end
    
    puts "Leaving assignment_statement '#{@sy.text}'" if DEBUG
    return AssignmentStatementNode.new(id, expr_node)
  end
  
  # TODO docs
  def call_statement(keys)
    puts "Entering call_statement '#{@sy.text}'" if DEBUG
    id = nil
    
    if @sy.type == TokenType::IDENT_TOKEN
      ident_check(@sy)
      id = @sy.text
      next_token() # grab the next token
    else
      error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'", keys | Statement.follow)
    end
    
    puts "Leaving call_statement '#{@sy.text}'" if DEBUG
    return CallStatementNode.new(id)
  end
  
  # TODO docs
  def begin_statement(keys)
    puts "Entering begin_statement '#{@sy.text}'" if DEBUG
    slist_node = nil
    
    slist_node = statement_list(keys | Set['end'] | Statement.follow)
    if @sy.type == TokenType::END_TOKEN
      next_token()
    else
      error("Line #{@sy.line_number}: expected 'end' but saw '#{@sy.text}'", keys | Statement.follow)
    end
    
    puts "Leaving begin_statement '#{@sy.text}'" if DEBUG
    return BeginStatementNode.new(slist_node) unless slist_node.nil?
  end
  
  # TODO docs
  def if_statement(keys)
    puts "Entering if_statement '#{@sy.text}'" if DEBUG
    cond_node      = nil
    statement_node = nil
    if_statement_a_node  = nil
    
    cond_node = condition(keys | Statement.follow | Set['then'])
    
    if @sy.type == TokenType::THEN_TOKEN
      next_token()
      statement_node = statement(keys | Statement.follow)
      if @sy.type == TokenType::ELSE_TOKEN
        if_statement_a_node = if_statement_a(keys | Statement.follow)
      end
    else
      error("Line #{@sy.line_number}: expected 'then' but saw '#{@sy.text}'", keys | Statement.follow)
    end
    
    puts "Leaving if_statement '#{@sy.text}'" if DEBUG
    return IfStatementNode.new(cond_node, statement_node, if_statement_a_node) unless statement_node.nil? and if_statement_a_node.nil?
    return IfStatementNode.new(cond_node, statement_node, nil)                 unless statement_node.nil?
    return IfStatementNode.new(cond_node, nil, nil) 
  end
  
  #TODO add docs
  def if_statement_a(keys)
    puts "Entering if_a_statement '#{@sy.text}'" if DEBUG
    statement_node = nil
    
    if @sy.type == TokenType::ELSE_TOKEN
      statement_node = statement(keys | Statement.follow)
    end
    
    puts "Leaving if_a_statement '#{@sy.text}'" if DEBUG
    return IfStatementANode.new(statement_node) unless statement_node.nil?
  end
  
  # TODO docs
  def while_statement(keys)
    puts "Entering while_statement '#{@sy.text}'" if DEBUG
    cond_node = nil
    statement_node = nil
    
    cond_node = condition(keys | Set['do'] | Statement.follow)
    if @sy.type == TokenType::DO_TOKEN
      next_token()
      statement_node = statement(keys | Statement.follow)
    else
      error("Line #{@sy.line_number}: expected 'do' but saw '#{@sy.text}'", keys | Statement.follow | Statement.first)
    end
    
    puts "Leaving while_statement '#{@sy.text}'" if DEBUG
    return WhileStatementNode.new(cond_node, statement_node) unless statement_node.nil?
    return WhileStatementNode.new(cond_node)
  end
  
  # TODO docs
  def print_statement(keys)
    puts "Entering print_statement '#{@sy.text}'" if DEBUG
    id = nil
    
    if @sy.type == TokenType::IDENT_TOKEN
      ident_check(@sy)
      id = @sy.text
      next_token()
    end
    
    puts "Leaving print_statement '#{@sy.text}'" if DEBUG
    return PrintStatementNode.new(id)
  end
  
  # TODO docs
  def read_statement(keys)
    puts "Entering read_statement '#{@sy.text}'" if DEBUG
    id = nil
    
    if @sy.type == TokenType::IDENT_TOKEN
      ident_check(@sy)
      id = @sy.text
      next_token()
    end
    
     puts "Leaving read_statement '#{@sy.text}'" if DEBUG
    return ReadStatementNode.new(id)
  end
  # <statement-list> -> <statement> <statement-A>
  def statement_list(keys)
    puts "Entering statement_list '#{@sy.text}'" if DEBUG
    state_node   = nil
    state_a_node = nil
    
    state_node   = statement(keys   | StatementList.follow | StatementA.first)
    state_a_node = statement_a(keys | StatementList.follow)
    
    puts "Leaving statement_list" if DEBUG
    return StatementListNode.new(state_node, state_a_node) unless state_node.nil? and state_a_node.nil?
    return StatementListNode.new(state_node, nil)          unless state_node.nil?
  end
  
  def statement_a(keys)
    puts "Entering statement_a '#{@sy.text}'" if DEBUG
    state_node   = nil
    state_a_node = nil
    
    if @sy.type == TokenType::SEMI_COL_TOKEN
      next_token()
      state_node   = statement(keys | StatementA.follow | StatementA.first)
      state_a_node = statement_a(keys | StatementA.follow)
    end
    puts "Leaving statment_a '#{@sy.text}'" if DEBUG
    
    return StatementANode.new(state_node, state_a_node) unless state_node.nil? and state_a_node.nil?
    return StatementANode.new(state_node, nil)          unless state_node.nil?
  end
  
  # const-decl -> 'const' <const-list> ';'
  # const-decl -> e
  def const_decl(keys)
    puts "Entering const_decl '#{@sy.text}'" if DEBUG
    const_list_node = nil
    
    if @sy.type == TokenType::CONST_TOKEN
      next_token()
      const_list_node = const_list(keys | ConstDecl.follow)
      if @sy.type == TokenType::SEMI_COL_TOKEN
        next_token();
      else
        error("Line #{@sy.line_number}: expected ';' but saw '#{@sy.text}'",keys | ConstDecl.follow)
      end
    end
    
    puts "Leaving const_decl '#{@sy.text}'" if DEBUG
    return ConstantDeclarationNode.new(const_list_node) unless const_list_node.nil?
  end
  
  # <const-list> -> [ident] '=' [number] <const-A>
  def const_list(keys)
    puts "Entering const_list '#{@sy.text}'" if DEBUG
    id           = nil
    val          = nil
    const_a_node = nil
    
    if @sy.type == TokenType::IDENT_TOKEN
      @stack.push @sy # push the token onto the stack
      id = @sy.text
      
      if (s = @stack.get_current_scope) == 'global' # check the current scope
        @sy.scope = EXTERNAL
      else # not global, local to some procedure
        @sy.scope     = INTERNAL
        @sy.proc_name = s
      end
        
      if @current_level != s # update current scope if needed
         @current_level = s
      end
      
      next_token()
      if @sy.type == TokenType::ASSIGN_TOKEN
        next_token()
        if @sy.type == TokenType::NUMERAL_TOKEN
          val = @sy.text
          next_token()
          const_a_node = const_a(keys | ConstList.follow)
        elsif @sy.type == TokenType::STR_LITERAL_TOKEN
          val = string_literal(keys | ConstList.follow)
          next_token()
          const_a_node = const_a(keys | ConstList.follow)
        else
          error("Line #{@sy.line_number}: expected 'numeral' but saw '#{@sy.text}'",keys | ConstA.first)
        end
      else
        error("Line #{@sy.line_number}: expected ':=' but saw '#{@sy.text}'",keys | ConstA.first)
      end
    else
      error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'",keys | ConstA.first)
    end 
    
    puts "Leaving const_list '#{@sy.text}" if DEBUG
    return ConstantListNode.new(id, val, const_a_node) unless const_a_node.nil?
    return ConstantListNode.new(id, val, nil)
  end
  
  # <const-A> -> ',' [ident] '=' [number] <const-A>
  # <const-A> -> e 
  def const_a(keys)
    puts "Entering const_a '#{@sy.text}'" if DEBUG
    id           = nil
    val          = nil
    const_a_node = nil
    
    if @sy.type == TokenType::COMMA_TOKEN
      next_token()
      if @sy.type == TokenType::IDENT_TOKEN
        @stack.push @sy # push the token onto the stack
        id = @sy.text
        
        if (s = @stack.get_current_scope) == 'global' # check the current scope
          @sy.scope = EXTERNAL
        else # not global, local to some procedure
          @sy.scope     = INTERNAL
          @sy.proc_name = s
        end
        
        if @current_level != s # update current scope if needed
           @current_level = s
        end
        
        next_token()
        if @sy.type == TokenType::ASSIGN_TOKEN
          next_token()
          if @sy.type == TokenType::NUMERAL_TOKEN
            val = @sy.text
            next_token()
            const_a_node = const_a(keys | ConstA.follow)
          elsif @sy.type == TokenType::STR_LITERAL_TOKEN
            val = string_literal(keys | ConstA.follow)
            next_token()
            const_a_node = const_a(keys | ConstA.follow)
          else
            error("Line #{@sy.line_number}: expected 'numeral' but saw '#{@sy.text}'",keys | ConstA.follow)
          end
        else
          error("Line #{@sy.line_number}: expected ':=' but saw '#{@sy.text}'",keys | ConstA.follow)
        end
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'",keys | ConstA.follow)
      end
    end
    
    puts "Leaving const_a '#{@sy.text}'" if DEBUG
    return ConstantANode.new(id, val, const_a_node) unless id.nil? and val.nil? and const_a_node.nil?
    return ConstantANode.new(id, val, nil)          unless id.nil? and val.nil?
  end
  
  # <var-decl> -> 'var' <ident-list> ';'
  # <var-decl> -> e 
  def var_decl(keys)
    puts "Entering var_decl '#{@sy.text}'" if DEBUG
    idlist_node = nil
    type_node   = nil
    
    if @sy.type == TokenType::VAR_TOKEN
      next_token()
      idlist_node = ident_list(keys | Set[';'] | VarDecl.follow)
      if @sy.type == TokenType::COLON_TOKEN
        next_token()
        type_node = type(keys | VarDecl.follow)
        if @sy.type == TokenType::SEMI_COL_TOKEN
          next_token()
        else
          error("Line #{@sy.line_number}: expected ';' but saw '#{@sy.text}'", keys | VarDecl.follow)
        end
      else
        error("Line #{@sy.line_number}: expected ':' but saw '#{@sy.text}'", keys | VarDecl.follow)
      end
    end
    
    puts "Leaving var_decl '#{@sy.text}" if DEBUG
    return VariableDeclarationNode.new(idlist_node, type_node)
  end

  # <proc_decl> -> e <proc-A>
  def proc_decl(keys)
    puts "Entering proc_decl '#{@sy.text}'" if DEBUG
    
    proc_a_node = proc_a(keys | ProcDecl.follow)
    
    puts "Leaving proc_decl" if DEBUG
    return ProcedureDeclarationNode.new(proc_a_node) unless proc_a_node.nil?
  end
  
  # <proc-A> -> 'procedure' [ident] ';' <block> ';' <proc-A>
  # <proc-A> -> e 
  def proc_a(keys)
    puts "Entering proc_a '#{@sy.text}'" if DEBUG
    id           = nil
    block_node   = nil
    proc_a_node  = nil
    
    if @sy.type == TokenType::PROCEDURE_TOKEN
      next_token()
      if @sy.type == TokenType::IDENT_TOKEN
        @stack.push @sy.text # push a new scope level onto the stack
        id = @sy.text
        next_token()
        if @sy.type == TokenType::SEMI_COL_TOKEN
          next_token()
          block_node = block(keys | ProcA.follow)
          if @sy.type == TokenType::SEMI_COL_TOKEN
            @stack.pop_level# remove the most recent scope from the stack
            next_token()
            proc_a_node = proc_a(keys | ProcA.follow)
          end
        else
          error("Line #{@sy.line_number}: expected ';' but saw '#{@sy.text}'",keys | ProcA.follow | Block.first)
        end
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'",keys | ProcA.follow | Set[';'])
      end
    end
    
    puts "Leaving proc_a '#{@sy.text}'" if DEBUG
    return ProcANode.new(id, block_node, proc_a_node) unless id.nil? and block_node.nil? and proc_a_node.nil?
    return ProcANode.new(id, block_node, nil)         unless id.nil? and block_node.nil?
    return ProcANode.new(id, nil, nil)                unless id.nil?
  end
  
  # <ident-list> -> [ident] <ident-A>
  def ident_list(keys)
    puts "Entering ident_list '#{@sy.text}'" if DEBUG
    id           = nil
    ident_a_node = nil
    
    if @sy.type == TokenType::IDENT_TOKEN
      @stack.push @sy # push the token onto the stack
      id = @sy.text
      
      if (s = @stack.get_current_scope) == 'global' # check the current scope
        @sy.scope = EXTERNAL
      else # not global, local to some procedure
        @sy.scope     = INTERNAL
        @sy.proc_name = s
      end
        
      if @current_level != s # update current scope if needed
         @current_level = s
      end
      
      next_token()
      ident_a_node = ident_a(keys | IdentList.follow)
    else
      error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'",keys | IdentList.follow)  
    end
    
    puts "Leaving ident_list '#{@sy.text}'" if DEBUG
    return IdentifierListNode.new(id, ident_a_node) unless id.nil?
    return IdentifierListNode.new(id, nil)
  end
  
  # <ident-A> -> ',' [ident] <ident-A>
  # <ident-A> -> e
  def ident_a(keys)
    puts "Entering ident_a '#{@sy.text}'" if DEBUG
    id           = nil
    ident_a_node = nil
    
    if @sy.type == TokenType::COMMA_TOKEN
      next_token()
      if @sy.type == TokenType::IDENT_TOKEN
        @stack.push @sy # push the token onto the stack
        id = @sy.text
        
        # scope stuff
        if (s = @stack.get_current_scope) == 'global' # check the current scope
          @sy.scope = EXTERNAL
        else # not global, local to some procedure
          @sy.scope     = INTERNAL
          @sy.proc_name = s
        end
        
        if @current_level != s # update current scope if needed
           @current_level = s
        end
        
        next_token()
        ident_a_node = ident_a(keys | IdentA.follow)
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'", keys | IdentA.follow)
      end
    end
    
    puts "Leaving ident_a '#{@sy.text}'" if DEBUG
    return IdentANode.new(id, ident_a_node) unless ident_a_node.nil?
    return IdentANode.new(id, nil) unless id.nil?
  end
  
  # <condition> -> 'odd' <expression>
  # <condition> -> <expression> <relop> <expression>
  def condition(keys)
    puts "Entering condition '#{@sy.text}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{Condition.first.to_a} but saw '#{@sy.text}'",
          keys | Condition.follow | Set['odd'] | Expression.first)
    expr_node_1 = nil
    relop_node  = nil
    expr_node_2 = nil
    
    if Set['odd'].include? @sy.text
      next_token()
      expr_node_1 = expression(keys | Condition.follow)      
    elsif Expression.first.include? @sy.text or Expression.first.include? "identifier"
      expr_node_1 = expression(keys | Condition.follow | Relop.first)      
      relop_node  = relop(keys | Condition.follow | Expression.first)     
      expr_node_2 = expression(keys | Condition.follow) 
    else
      error("Line #{@sy.line_number}: expected #{Condition.first.to_a} but saw '#{@sy.text}'",
            keys | Condition.follow)
    end
    
    puts "Leaving condition '#{@sy.text}" if DEBUG
    return ConditionNode.new(expr_node_1, nil, nil) if expr_node_2.nil? and relop_node.nil?
    return ConditionNode.new(expr_node_1, relop_node, expr_node_2)
  end
  
  # <expression> -> <term> <expression-A>
  # <expression> -> <add-subop> <term> <expression-A>
  def expression(keys)
    puts "Entering expression '#{@sy.text}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{Expression.first.to_a} but saw '#{@sy.text}'",
          keys | Expression.follow | Term.first | AddSubOp.first)
    term_node   = nil
    expr_a_node = nil
          
    if Term.first.include? @sy.text or Term.first.include? "identifier"
      term_node   = term(keys | Expression.follow | ExpressionA.first)
      expr_a_node = expression_a(keys | Expression.follow)
    else
      error("Line #{@sy.line_number}: expected #{Expression.first.to_a} but saw '#{@sy.text}'",
            keys | Expression.follow)  
    end
    
    puts "Leaving expression '#{@sy.text}" if DEBUG
    return ExpressionNode.new(term_node, expr_a_node) unless expr_a_node.nil?
    return ExpressionNode.new(term_node, nil)
  end
  
  # <expression-A> -> <add-subop> <term> <expression-A>
  # <expression-A> -> e
  def expression_a(keys)
    puts "Entering expression_a '#{@sy.text}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{ExpressionA.first.to_a} but saw '#{@sy.text}'",
          keys | ExpressionA.follow | AddSubOp.first | EMPTY_SET)
    add_sub_node = nil
    term_node    = nil
    expr_a_node  = nil
    
    if AddSubOp.first.include? @sy.text
      add_sub_node = add_sub_op(keys | ExpressionA.follow | Term.first)
      term_node    = term(keys | ExpressionA.follow | ExpressionA.first)
      expr_a_node = expression_a(keys | ExpressionA.follow)
    end
    
    puts "Leaving expression_a '#{@sy.text}" if DEBUG
    return ExpressionANode.new(add_sub_node, term_node, expr_a_node) unless expr_a_node.nil?
    return ExpressionANode.new(add_sub_node, term_node, nil)
  end
  
  # <term> -> <factor> <term-A>
  def term(keys)
    puts "Entering term '#{@sy.text}'" if DEBUG
    factor_node = nil
    term_a_node = nil
    
    factor_node = factor(keys | Term.follow | TermA.first)
    term_a_node = term_a(keys | Term.follow)
    
    puts "Leaving term '#{@sy.text}"if DEBUG
    return TermNode.new(factor_node, term_a_node) unless term_a_node.nil?
    return TermNode.new(factor_node, nil) 
  end
  
  # <term-A> -> <mult-divop> <factor> <term-A>
  # <term-A> -> e
  def term_a(keys)
    puts "Entering term_a '#{@sy.text}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{TermA.first.to_a} but saw '#{@sy.text}'", 
          keys | TermA.follow | MultDivOp.first | EMPTY_SET)
    mult_div_node = nil
    factor_node   = nil
    term_a_node   = nil
    
    if MultDivOp.first.include? @sy.text
      mult_div_node = mult_div_op(keys | TermA.follow | Factor.first)
      factor_node   = factor(keys | TermA.follow | TermA.first)
      term_a_node   = term_a(keys | TermA.follow)
    end
    
    puts "Leaving term_a '#{@sy.text}"if DEBUG
    return TermANode.new(mult_div_node, factor_node, term_a_node) unless term_a_node.nil?
    return TermANode.new(mult_div_node, factor_node, nil)
  end
  
  # <factor> -> [ident]
  # <factor> -> [number]
  # <factor> -> '(' <expression> ')'
  def factor(keys)
    puts "Entering factor '#{@sy.text}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{Factor.first} but saw '#{@sy.text}'",
          keys | Factor.follow | Factor.first)
    val = nil
    
    if @sy.type == TokenType::IDENT_TOKEN
      ident_check(@sy)
      val = @sy.text
      next_token()
    elsif @sy.type == TokenType::NUMERAL_TOKEN
      val = @sy.text
      next_token()
    elsif @sy.type == TokenType::L_PAREN_TOKEN
      next_token()
      val = expression(keys | Factor.follow | Set['('])
      if @sy.type == TokenType::R_PAREN_TOKEN
        next_token()
      else
        error("Line #{@sy.line_number}: expected ')' but saw '#{@sy.text}'", keys | Factor.follow)
      end
    elsif @sy.type == TokenType::STR_LITERAL_TOKEN
      val = string_literal(keys | Factor.follow)
      next_token()
    else
      error("Line #{@sy.line_number}: expected #{Factor.first.to_a} but saw '#{@sy.text}'",
            keys | Factor.follow)
    end
    
    puts "Leaving factor '#{@sy.text}" if DEBUG
    return FactorNode.new(val)
  end
  
  # <add-subop> -> '+'
  # <add-subop> -> '-'
  def add_sub_op(keys)
    puts "Entering add_sub_op '#{@sy.text}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{AddSubOp.first.to_a} but saw '#{@sy.text}'",
          keys | AddSubOp.follow | AddSubOp.first)
    op = nil
    
    if @sy.type == TokenType::PLUS_TOKEN or @sy.type == TokenType::MINUS_TOKEN
      op = @sy.text
      next_token()
    else
      error("Line #{@sy.line_number}: expected #{AddSubOp.first.to_a} but saw '#{@sy.text}'",
            keys | AddSubOp.follow)
    end
    
    puts "Leaving add_sub_op '#{@sy.text}" if DEBUG
    return AddSubOpNode.new(op)
  end
  
  # <mult-divop> -> '*' | '\'
  def mult_div_op(keys)
    puts "Entering mult_div_op '#{@sy.text}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{MultDivOp.first.to_a} but saw '#{@sy.text}'",
          keys | MultDivOp.follow | MultDivOp.first)
    op = nil
    
    if @sy.type == TokenType::MULT_TOKEN or @sy.type == TokenType::F_SLASH_TOKEN
      next_token()
    else
      error("Line #{@sy.line_number}: expected #{MultDivOp.first.to_a} but saw '#{@sy.text}'", 
            keys | MultDivOp.follow)
    end
    
    puts "Leaving mult_div_op '#{@sy.text}"if DEBUG
    return MultDivOpNode.new(op)
  end
  
  # <relop> -> '=' | '<>' | '<' | '>' | '<=' | '>='
  def relop(keys)
    puts "Entering relop '#{@sy.text}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{Relop.first.to_a} but saw '#{@sy.text}'",
          keys | Relop.follow | Relop.first)
    op = nil
    
    if @sy.type == TokenType::EQUALS_TOKEN      or @sy.type == TokenType::RELOP_NEQ_TOKEN or
       @sy.type == TokenType::RELOP_LT_TOKEN    or @sy.type == TokenType::RELOP_GT_TOKEN  or
       @sy.type == TokenType::RELOP_LT_EQ_TOKEN or @sy.type == TokenType::RELOP_GT_EQ_TOKEN 
       op = @sy.text
       next_token()
    else
      error("Line #{@sy.line_number}: expected #{Relop.first.to_a} but saw '#{@sy.text}'",
            keys | Relop.follow)
    end
    
    puts "Leaving relop '#{@sy.text}" if DEBUG
    return RelOpNode.new(op)
  end
  
  def string_literal(keys)
    puts "Entering string_literal '#{@sy.text}'" if DEBUG
    text = @sy.text
    puts "Leaving string_literal '#{@sy.text}'" if DEBUG
    return StringLiteralNode.new(text)
  end
end
