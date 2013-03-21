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
DEBUG = true

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
  def next_token
    @sy = @tokenizer.next_token
    
    # ignore EOL tokens since no productions would accept them
    while @sy.type == TokenType::EOL_TOKEN
      @sy = @tokenizer.next_token
    end
  end
  
  # insert IDENT_TOKENs into the Symbol Table if they do not 
  # exist there already
  def check_table(token)
    @symbol_table.insert(token) if !@symbol_table.contains(token) 
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
    puts ""
    while not keys.include? @sy.text
      puts "SKIPPED TOKEN: #{@sy.text}"
      next_token
    end
    puts ""
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
    elsif @sy.type == TokenType::STRING_TOKEN
      test = "string"
    else
      test = @sy.text
    end
    
    if not keys.include? test
       $stderr.puts "ERROR line ##{@sy.line_number} #{@sy.type} #{@sy.text}"
       error(mesg, keys)
    end
  end
  
  # returns an AST to the main program
  def parse
    @stack.push @current_level
    program_node = program(Sets::EMPTY_SET) 
    
    return SyntaxTree.new(program_node)
  end
  
  # <program> -> 'program' <block> '.'
  def program(keys)
    puts "Entering program '#{@sy.text}'" if DEBUG
    block_node   = nil
    program_name = nil
    
    next_token # move past the default token EMPTY
    
    if @sy.type == TokenType::PROGRAM_TOKEN
      next_token
      if @sy.type == TokenType::IDENT_TOKEN
        program_name = @sy.text # store the name of the program
        next_token
        block_node = block(keys | Set['.'] | Program.follow)
      else
        error("Line #{@sy.line_number} expected an identifier, but saw '#{@sy.text}'", keys | Program.follow)
      end
    else
      error("Line #{@sy.line_number} expected a 'program', but saw '#{@sy.text}'", keys | Program.follow)
    end
    
    
    if @sy.type == TokenType::END_TOKEN
      next_token
      if @sy.type == TokenType::EOF_TOKEN
        # DONE
      else
        error("Line #{@sy.line_number} expected EOF, but saw '#{@sy.text}'", keys | Program.follow)
      end
    else
      error("Line #{@sy.line_number} expected a 'end', but saw '#{@sy.text}'", keys | Program.follow)
    end
    
    puts "Leaving program '#{@sy}'" if DEBUG
    return ProgramNode.new(program_name, block_node)
  end
  
  #                 e
  # <block> -> <declaration> <statement>
  def block(keys)
    puts "Entering block '#{@sy}'" if DEBUG
    decl_node  = declaration(keys | Block.follow | Statement.first)
    state_node = statement(keys | Block.follow)
    
    puts "Leaving block '#{@sy}'" if DEBUG
    return BlockNode.new(decl_node, state_node) if decl_node and state_node
    return BlockNode.new(decl_node, nil)        if decl_node
    return BlockNode.new(nil, state_node)       if state_node
  end
  
  #                       e           e           e
  # <declaration> -> <const-decl> <var-decl> <func-decl>
  def declaration(keys)
    puts "Entering declaration '#{@sy}'" if DEBUG
    const_decl_node = const_decl(keys | Declaration.follow | VarDecl.first | FuncDecl.first)
    var_decl_node   = var_decl(keys   | Declaration.follow | FuncDecl.first)
    func_decl_node  = func_decl(keys  | Declaration.follow)
    
    puts "Leaving declaration '#{@sy.text}" if DEBUG
    return DeclarationNode.new(const_decl_node, var_decl_node, func_decl_node)
  end
  
  # type -> 'integer' | 'boolean' | 'string' | <array>
  def type(keys)
    type = nil 
    puts "Entering type '#{@sy}'" if DEBUG
    
    if Type.first.include? @sy.text
      if @sy.type == TokenType::ARRAY_TOKEN
        type = array(keys | Type.follow)
      else
        type = @sy.text
        next_token
      end
    else
      error("Invalid type #{@sy.text}", keys | Type.follow)
    end   
    
    puts "Leaving type '#{@sy}'" if DEBUG
    return TypeNode.new(type)
  end
  
  # selector -> '[' <expression> ']' | e
  def selector(keys)
    puts "Entering selector '#{@sy}'" if DEBUG
    index = nil
    if @sy.type == TokenType::LPAREN_TOKEN
      
    end
    puts "Leaving  selector '#{@sy}'" if DEBUG
  end
  
  # <array> -> 'array' <expression> 'of' <type>
  def array(keys)
    puts "Entering array '#{@sy}'" if DEBUG
    type = nil
    size = nil
    
    if @sy.type == TokenType::ARRAY_TOKEN
      next_token
      size = expression(keys | Array.follow)
      if @sy.type == TokenType::OF_TOKEN
        next_token
        type = type(keys | Array.follow)
      else
        error("Line #{@sy.line_number} expected 'of', but saw '#{@sy.text}'", keys | Array.follow)
      end
    else
      error("Line #{@sy.line_number} expected 'array', but saw '#{@sy.text}'", keys | Array.follow)
    end
    
    puts "Leaving  array '#{@sy}'" if DEBUG
    return ArrayNode.new(size, type)
  end
  
  # statement -> <assign-statement> | <call-statement>  | <begin-statement> | <if-statement>     | 
  #              <while-statement>  | <print-statement> | <read-statement>  | <return-statement> | 
  #              <for-statement>    |    e
  def statement(keys)
    statement_node = nil     
    puts "Entering statement '#{@sy}'" if DEBUG
    
    check("Line #{@sy.line_number}: expecting #{Statement.first.to_a} but saw '#{@sy.text}'", 
          keys | Statement.first | Statement.follow)
          
    statement_node = case @sy.type
     when TokenType::IDENT_TOKEN  then assignment_statement(keys | Statement.follow)
     when TokenType::CALL_TOKEN   then call_statement(keys | Statement.follow)
     when TokenType::BEGIN_TOKEN  then begin_statement(keys | Statement.follow)
     when TokenType::IF_TOKEN     then if_statement(keys | Statement.follow)
     when TokenType::WHILE_TOKEN  then while_statement(keys | Statement.follow)
     when TokenType::PRINT_TOKEN  then print_statement(keys | Statement.follow)
     when TokenType::READ_TOKEN   then read_statement(keys | Statement.follow)
     when TokenType::RETURN_TOKEN then return_statement(keys | Statement.follow)
     when TokenType::FOR_TOKEN    then for_statement(keys | Statement.follow)
     end
=begin
    if @sy.type == TokenType::IDENT_TOKEN
      statement_node = assignment_statement(keys | Statement.follow)
    elsif @sy.type == TokenType::CALL_TOKEN
      next_token # grab the next token
      statement_node = call_statement(keys | Statement.follow)
    elsif @sy.type == TokenType::BEGIN_TOKEN
      next_token # grab the next token
      statement_node = begin_statement(keys | Statement.follow)
    elsif @sy.type == TokenType::IF_TOKEN
      next_token # grab the next token
      statement_node = if_statement(keys | Statement.follow)
    elsif @sy.type == TokenType::WHILE_TOKEN
      next_token
      statement_node = while_statement(keys | Statement.follow)
    elsif @sy.type == TokenType::PRINT_TOKEN
      next_token;
      statement_node = print_statement(keys | Statement.follow)
    elsif @sy.type == TokenType::READ_TOKEN
      next_token
      statement_node = read_statement(keys | Statement.follow)
    elsif @sy.type == TokenType::RETURN_TOKEN
      next_token
      statement_node = return_statement(keys | Statement.follow)
    elsif @sy.type == TokenType::FOR_TOKEN
      next_token
      statement_node = for_statement(keys | Statement.follow)
    end
=end
    puts "Leaving statement '#{@sy}'" if DEBUG
    
    return StatementNode.new(statement_node) if statement_node
    return StatementNode.new(nil)
  end
  
  # TODO docs
  def assignment_statement(keys)
    puts "Entering assignment_statement '#{@sy}'" if DEBUG
    id_list_node   = nil
    expr_list_node = nil
    
    # check for multi identifier assignment
    id_list_node = identifier_list(keys | Statement.follow)
    
    # check for assignment op
    if @sy.type == TokenType::ASSIGN_TOKEN
      next_token
      expr_list_node = expression_list(keys | Statement.follow)
    else
      error("Line #{@sy.line_number}: expected ':=' but saw '#{@sy.text}'", keys | Statement.follow)
    end
    
    puts "Leaving assignment_statement '#{@sy}'" if DEBUG
    return AssignmentStatementNode.new(id_list_node, expr_list_node)
  end
  
  # TODO docs
  def expression_list(keys)
    puts "Entering expression_list '#{@sy}'" if DEBUG
    expr_node        = nil
    expr_list_a_node = nil
    
    expr_node        = expression(keys | ExpressionList.follow)
    expr_list_a_node = expression_list_a(keys | ExpressionList.follow)
    
    puts "Leaving expression_list '#{@sy}'" if DEBUG
    return ExpressionListNode.new(expr_node, expr_list_a_node) if expr_node and expr_list_a_node
    return ExpressionListNode.new(expr_node, nil)              if expr_node  
  end
  
  def expression_list_a(keys)
    puts "Entering expression_list_a '#{@sy}'" if DEBUG
    expr_node        = nil
    expr_list_a_node = nil
    
    if @sy.type == TokenType::COMMA_TOKEN
      next_token
      expr_node        = expression(keys | ExpressionList.follow)
      expr_list_a_node = expression_list_a(keys | ExpressionList.follow)
    end
    
    puts "Leaving expression_list_a '#{@sy}'" if DEBUG
    return ExpressionListANode.new(expr_node, expr_list_a_node) if expr_node and expr_list_a_node
    return ExpressionListANode.new(expr_node, nil)              if expr_node  
    return ExpressionListANode.new(nil, nil)
  end
  
  # TODO docs
  def call_statement(keys)
    puts "Entering call_statement '#{@sy}'" if DEBUG
    id = nil
    
    if @sy.type == TokenType::CALL_TOKEN
      next_token
      if @sy.type == TokenType::IDENT_TOKEN
        ident_check(@sy)
        id = @sy.text
        next_token # grab the next token
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'", keys | Statement.follow)
      end
    else
      error("Line #{@sy.line_number}: expected 'call' but saw '#{@sy.text}'", keys | Statement.follow)
    end
    
    puts "Leaving call_statement '#{@sy}'" if DEBUG
    return CallStatementNode.new(id)
  end
  
  # begin_statement -> 'begin' <statement-list> 'end'
  def begin_statement(keys)
    puts "Entering begin_statement '#{@sy}'" if DEBUG
    slist_node = nil
    
    if @sy.type == TokenType::BEGIN_TOKEN
      next_token
      slist_node = statement_list(keys | StatementList.follow | Statement.follow)
      if @sy.type == TokenType::END_TOKEN
        next_token
      else
        error("Line #{@sy.line_number}: expected 'end' but saw '#{@sy.text}'", keys | Statement.follow)
      end
    else
      error("Line #{@sy.line_number}: expected 'begin' but saw '#{@sy.text}'", keys | Statement.follow)
    end
    
    puts "Leaving begin_statement '#{@sy}'" if DEBUG
    return BeginStatementNode.new(slist_node) if slist_node
  end
  
  # TODO docs
  def if_statement(keys)
    puts "Entering if_statement '#{@sy}'" if DEBUG
    cond_node            = nil
    statement_node       = nil
    if_statement_a_node  = nil
    
    if @sy.type == TokenType::IF_TOKEN
      next_token
      cond_node = condition(keys | Condition.follow | Statement.follow | Set['then'])
      if @sy.type == TokenType::THEN_TOKEN
        next_token
        statement_node = statement(keys | Statement.follow)
        if_statement_a_node = if_statement_a(keys | Statement.follow)
        if @sy.type == TokenType::END_TOKEN
          next_token
        else
          error("Line #{@sy.line_number}: expected 'end' but saw '#{@sy.text}'", keys | Statement.follow)     
        end
      else
        error("Line #{@sy.line_number}: expected 'then' but saw '#{@sy.text}'", keys | Statement.follow)
      end
    else
      error("Line #{@sy.line_number}: expected 'if' but saw '#{@sy.text}'", keys | Statement.follow)
    end
    
    puts "Leaving if_statement '#{@sy}'" if DEBUG
    return IfStatementNode.new(cond_node, statement_node, if_statement_a_node) if statement_node and if_statement_a_node
    return IfStatementNode.new(cond_node, statement_node, nil)                 if statement_node
    return IfStatementNode.new(cond_node, nil, nil) 
  end
  
  #TODO add docs
  def if_statement_a(keys)
    puts "Entering if_a_statement '#{@sy}'" if DEBUG
    statement_node = nil
    
    if @sy.type == TokenType::ELSE_TOKEN
      next_token
      statement_node = statement(keys | Statement.follow) 
    end
    
    puts "Leaving if_a_statement '#{@sy}'" if DEBUG
    return IfStatementANode.new(statement_node) if statement_node
    return IfStatementANode.new(nil)
  end
  
  # TODO docs
  def while_statement(keys)
    puts "Entering while_statement '#{@sy}'" if DEBUG
    cond_node = nil
    statement_node = nil
    
    if @sy.type == TokenType::WHILE_TOKEN
      next_token
      cond_node = condition(keys | Set['do'] | Statement.follow)
      if @sy.type == TokenType::DO_TOKEN
        next_token
        statement_node = statement(keys | Statement.follow)
        if @sy.type == TokenType::END_TOKEN
          next_token
        else
          error("Line #{@sy.line_number}: expected 'end' but saw '#{@sy.text}'", keys | Statement.follow)
        end
      else
        error("Line #{@sy.line_number}: expected 'do' but saw '#{@sy.text}'", keys | Statement.follow)
      end
    else
      error("Line #{@sy.line_number}: expected 'while' but saw '#{@sy.text}'", keys | Statement.follow)
    end
    
    puts "Leaving while_statement '#{@sy}'" if DEBUG
    return WhileStatementNode.new(cond_node, statement_node) unless statement_node.nil?
    return WhileStatementNode.new(cond_node)
  end
  
  # print-statement -> 'print' <expression-list>
  def print_statement(keys)
    puts "Entering print_statement '#{@sy}'" if DEBUG
    expr_list_node = nil
    
    if @sy.type == TokenType::PRINT_TOKEN
      next_token
      expr_list_node = expression_list(keys | Statement.follow)
    else
      error("Line #{@sy.line_number}: expected 'print' but saw '#{@sy.text}'", keys | Statement.follow)
    end
    
    puts "Leaving print_statement '#{@sy}'" if DEBUG
    return PrintStatementNode.new(expr_list_node)
  end
  
  # TODO docs
  def read_statement(keys)
    puts "Entering read_statement '#{@sy}'" if DEBUG
    id = nil
    
    if @sy.type == TokenType::READ_TOKEN
      next_token
      if @sy.type == TokenType::IDENT_TOKEN
        ident_check(@sy)
        id = @sy.text
        next_token
      end
    else
      error("Line #{@sy.line_number}: expected 'read' but saw '#{@sy.text}'", keys | Statement.follow)
    end
    
     puts "Leaving read_statement '#{@sy}'" if DEBUG
    return ReadStatementNode.new(id)
  end
  
  # <return-statement> -> <expression>
  # a procedure can return an expression or an identifier
  # the <expression> non-terminal can represent both of those
  def return_statement(keys)
    puts "Entering return_statement '#{@sy}'" if DEBUG
    
    if @sy.type == TokenType::RETURN_TOKEN
      next_token
      expr_node = expression(keys | Statement.follow)
    else
      error("Line #{@sy.line_number}: expected 'return' but saw '#{@sy.text}'", keys | Statement.follow)
    end
    
    puts "Leaving  return_statement '#{@sy}'" if DEBUG
    return ReturnStatementNode.new(expr_node)
  end
  
  def for_statement(keys)
    puts "Entering for_statement '#{@sy}'" if DEBUG  
    id = nil
    iterable = nil
    statement_node = nil
    
    if @sy.type == TokenType::FOR_TOKEN
      next_token
      if @sy.type == TokenType::IDENT_TOKEN
        ident_check(@sy)
        id = @sy.text
        next_token
        if @sy.type == TokenType::IN_TOKEN
          next_token
          iterable = iterable(keys | Statement.follow)
          if @sy.type == TokenType::DO_TOKEN
            next_token
            statement_node = statement(keys | Statement.follow)
            if @sy.type == TokenType::END_TOKEN
              next_token
            else
              error("Line #{@sy.line_number}: expected 'while' but saw '#{@sy.text}'", keys | Statement.follow)
            end
          else
            error("Line #{@sy.line_number}: expected 'do' but saw '#{@sy.text}'", keys | Statement.follow)
          end
        else
          error("Line #{@sy.line_number}: expected 'in' but saw '#{@sy.text}'", keys | Statement.follow)
        end
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'", keys | Statement.follow)
      end
    else
      error("Line #{@sy.line_number}: expected 'for' but saw '#{@sy.text}'", keys | Statement.follow)
    end
    
    puts "Leaving  for_statement '#{@sy}'" if DEBUG  
    return ForStatementNode.new(id, iterable, statement_node)
  end
  
  # <statement-list> -> <statement> <statement-A>
  def statement_list(keys)
    puts "Entering statement_list '#{@sy}'" if DEBUG
    state_node   = nil
    state_a_node = nil
    
    state_node   = statement(keys   | StatementList.follow | StatementA.first)
    state_a_node = statement_a(keys | StatementList.follow)
    
    puts "Leaving statement_list '#{@sy}'" if DEBUG
    return StatementListNode.new(state_node, state_a_node) if state_node and state_a_node
    return StatementListNode.new(state_node, nil)          if state_node
  end
  
  def statement_a(keys)
    puts "Entering statement_a '#{@sy}'" if DEBUG
    state_node   = nil
    state_a_node = nil
    
    if @sy.type == TokenType::SEMI_COL_TOKEN
      next_token
      state_node   = statement(keys | StatementA.follow | StatementA.first)
      state_a_node = statement_a(keys | StatementA.follow)
    end
    
    puts "Leaving statement_a '#{@sy}'" if DEBUG
    return StatementANode.new(state_node, state_a_node) if state_node and state_a_node
    return StatementANode.new(state_node, nil)          if state_node
    return StatementANode.new(nil, nil)
  end
  
  # const-decl -> 'const' <const-list> ';'
  # const-decl -> e
  def const_decl(keys)
    puts "Entering const_decl '#{@sy}'" if DEBUG
    const_list_node = nil
    
    if @sy.type == TokenType::CONST_TOKEN
      next_token
      const_list_node = const_list(keys | ConstDecl.follow)
      if @sy.type == TokenType::SEMI_COL_TOKEN
        next_token;
      else
        error("Line #{@sy.line_number}: expected ';' but saw '#{@sy.text}'",keys | ConstDecl.follow)
      end
    end
    
    puts "Leaving const_decl '#{@sy}'" if DEBUG
    return ConstantDeclarationNode.new(const_list_node) unless const_list_node.nil?
  end
  
  # <const-list> -> [ident] '=' [number] <const-A>
  def const_list(keys)
    puts "Entering const_list '#{@sy}'" if DEBUG
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
        
      check_table(@sy)
  
      if @current_level != s # update current scope if needed
         @current_level = s
      end
      
      next_token
      if @sy.type == TokenType::ASSIGN_TOKEN
        next_token
        if @sy.type == TokenType::NUMERAL_TOKEN
          val = @sy.text
          next_token
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
    puts "Entering const_a '#{@sy}'" if DEBUG
    id           = nil
    val          = nil
    const_a_node = nil
    
    if @sy.type == TokenType::COMMA_TOKEN
      next_token
      if @sy.type == TokenType::IDENT_TOKEN
        @stack.push @sy # push the token onto the stack
        id = @sy.text
        
        if (s = @stack.get_current_scope) == 'global' # check the current scope
          @sy.scope = EXTERNAL
        else # not global, local to some procedure
          @sy.scope     = INTERNAL
          @sy.proc_name = s
        end
        
        check_table(@sy)
        
        if @current_level != s # update current scope if needed
           @current_level = s
        end
        
        next_token
        if @sy.type == TokenType::ASSIGN_TOKEN
          next_token
          if @sy.type == TokenType::NUMERAL_TOKEN
            val = @sy.text
            next_token
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
    
    puts "Leaving const_a '#{@sy}'" if DEBUG
    return ConstantANode.new(id, val, const_a_node) unless id.nil? and val.nil? and const_a_node.nil?
    return ConstantANode.new(id, val, nil)          unless id.nil? and val.nil?
  end
  
  # <var-decl> -> 'var' <ident-list> ';'
  # <var-decl> -> e 
  def var_decl(keys)
    puts "Entering var_decl '#{@sy}'" if DEBUG
    idlist_node   = nil
    type_node     = nil
    var_decl_node = nil
    
    if @sy.type == TokenType::VAR_TOKEN
      next_token
      idlist_node = identifier_list(keys | Set[';'] | VarDecl.follow)
      if @sy.type == TokenType::COLON_TOKEN
        next_token
        type_node = type(keys | VarDecl.follow)
        if @sy.type == TokenType::SEMI_COL_TOKEN
          next_token
          var_decl_node = var_decl(keys | VarDecl.follow)
        else
          error("Line #{@sy.line_number}: expected ';' but saw '#{@sy.text}'", keys | VarDecl.follow)
        end
      else
        error("Line #{@sy.line_number}: expected ':' but saw '#{@sy.text}'", keys | VarDecl.follow)
      end
    end
    
    puts "Leaving var_decl '#{@sy.text}" if DEBUG
    return VariableDeclarationNode.new(idlist_node, type_node, var_decl_node)
  end

  # <proc_decl> -> <proc-A>
  def func_decl(keys)
    puts "Entering func_decl '#{@sy}'" if DEBUG
    
    func_a_node = func_a(keys | FuncDecl.follow)
    
    puts "Leaving func_decl '#{@sy}'" if DEBUG
    return FunctionDeclarationNode.new(func_a_node) if func_a_node
  end
  
  # <proc-A> -> 'procedure' [ident] ';' <block> ';' <proc-A>
  # <proc-A> -> e 
  def func_a(keys)
    puts "Entering func_a '#{@sy}'" if DEBUG
    id               = nil
    block_node       = nil
    func_a_node      = nil
    fparam_list_node = nil
    return_type_node = nil
    
    if @sy.type == TokenType::FUNCTION_TOKEN
      next_token
      if @sy.type == TokenType::IDENT_TOKEN
        @stack.push @sy.text # push a new scope level onto the stack
        id = @sy.text
        @sy.scope = EXTERNAL
        check_table(@sy) 
        next_token
        fparam_list_node = formal_parameter_list(keys | FuncA.follow)
        if @sy.type == TokenType::ARROW_TOKEN
          next_token
          return_type_node = type(keys | FuncA.follow)
          block_node = block(keys | FuncA.follow)
          if @sy.type == TokenType::END_TOKEN
            @stack.pop_level # remove the most recent scope from the stack
            next_token
            func_a_node = func_decl(keys | FuncA.follow) # check for another procedure
          else
            error("Line #{@sy.line_number}: expected 'end' but saw '#{@sy.text}'",keys | FuncA.follow | Set['end'])
          end
        else
          error("Line #{@sy.line_number}: expected '->' but saw '#{@sy.text}'",keys | FuncA.follow | Block.first)
        end
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'", keys | FuncA.follow | Set['('])
      end
    end
    
    puts "Leaving proc_a '#{@sy}'" if DEBUG
    return FuncANode.new(id, block_node, func_a_node) if id and block_node and func_a_node
    return FuncANode.new(id, block_node, nil)         if id and block_node
    return FuncANode.new(id, nil, nil)                if id
  end
  
  def formal_parameter_list(keys)
    puts "Entering parameter_list '#{@sy}'" if DEBUG
    id                 = nil
    fparam_list_a_node = nil
    type_node          = nil
    
    if @sy.type == TokenType::L_PAREN_TOKEN
      next_token
      if @sy.type == TokenType::IDENT_TOKEN
        @stack.push @sy
        id = @sy.text
        @sy.scope     = INTERNAL
        @sy.proc_name = @stack.get_current_scope
        check_table(@sy)
        next_token
        if @sy.type == TokenType::COLON_TOKEN
          next_token
          type_node = type(keys | ParameterListA.follow)
          fparam_list_a_node = formal_parameter_list_a(keys | ParameterList.follow)
          if @sy.type == TokenType::R_PAREN_TOKEN
            next_token
          else
            error("Line #{@sy.line_number}: expected ')' but saw '#{@sy.text}", keys | ParameterList.follow)
          end
        else
          error("Line #{@sy.line_number}: expected ':' but saw '#{@sy.text}'", keys | ParameterList.follow)
        end
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'", keys | ParameterList.follow)
      end
    end
    
    puts "Leaving parameter_list  '#{@sy}'" if DEBUG
    return ParameterListNode.new(id, type_node, fparam_list_a_node) if id and type_node and fparam_list_a_node
    return ParameterListNode.new(id, type_node, nil)                if id and type_node
    return nil
  end
  
  def formal_parameter_list_a(keys)
    puts "Entering parameter_list_a '#{@sy}'" if DEBUG
    id        = nil
    type_node = nil
    param_list_node = nil
    
    if @sy.type == TokenType::COMMA_TOKEN
      next_token
      if @sy.type == TokenType::IDENT_TOKEN
        @stack.push @sy 
        id = @sy.text
        @sy.scope     = INTERNAL
        @sy.proc_name = @stack.get_current_scope
        check_table(@sy)
        next_token
        if @sy.type == TokenType::COLON_TOKEN
          next_token
          type_node = type(keys | ParameterListA.follow)
          param_list_node = formal_parameter_list_a(keys | ParameterListA.follow)
        else
          error("Line #{@sy.line_number}: expected ':' but saw '#{@sy.text}'", keys | ParameterListA.follow)
        end
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'", keys | ParameterListA.follow)
      end
    end
    
    puts "Leaving  parameter_list_a '#{@sy}'" if DEBUG
    return ParameterListNode.new(id, type_node, param_list_node) if id and type_node and param_list_node
    return ParameterListNode.new(id, type_node, nil)             if id and type_node
    return nil
  end
  
  # <ident-list> -> [ident] <ident-A>
  def identifier_list(keys)
    puts "Entering identifier_list '#{@sy}'" if DEBUG
    id           = nil
    identifier_list_a_node = nil
    
    if @sy.type == TokenType::IDENT_TOKEN
      @stack.push @sy # push the token onto the stack
      id = @sy.text
      
      if (s = @stack.get_current_scope) == EXTERNAL # check the current scope
        @sy.scope = EXTERNAL
      else # not global, local to some procedure
        @sy.scope     = INTERNAL
        @sy.proc_name = s
      end
        
      check_table(@sy)
      
      if @current_level != s # update current scope if needed
         @current_level = s
      end
      
      next_token
      identifier_list_a_node = identifier_list_a(keys | IdentList.follow)
    else
      error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'",keys | IdentList.follow)  
    end
    
    puts "Leaving identifier_list '#{@sy}'" if DEBUG
    return IdentifierListNode.new(id, identifier_list_a_node) if identifier_list_a_node and id
    return IdentifierListNode.new(id, nil)                    if id
  end
  
  # <ident-A> -> ',' [ident] <ident-A>
  # <ident-A> -> e
  def identifier_list_a(keys)
    puts "Entering identifier_list_a '#{@sy}'" if DEBUG
    id           = nil
    identifier_list_a_node = nil
    
    if @sy.type == TokenType::COMMA_TOKEN
      next_token
      if @sy.type == TokenType::IDENT_TOKEN
        @stack.push @sy # push the token onto the stack
        id = @sy.text
        
        # scope stuff
        if (s = @stack.get_current_scope) == EXTERNAL # check the current scope
          @sy.scope = EXTERNAL
        else # not global, local to some procedure
          @sy.scope     = INTERNAL
          @sy.proc_name = s
        end
        
        check_table(@sy)
        
        if @current_level != s # update current scope if needed
           @current_level = s
        end
        
        next_token
        identifier_list_a_node = identifier_list_a(keys | IdentA.follow)
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'", keys | IdentA.follow)
      end
    end
    
    puts "Leaving identifier_list_a '#{@sy}'" if DEBUG
    return IdentifierListANode.new(id, identifier_list_a_node) if id and identifier_list_a_node
    return IdentifierListANode.new(id, nil)                    if id
    return nil
  end
  
  # <condition> -> 'odd' <expression>
  # <condition> -> <expression> <relop> <expression>
  def condition(keys)
    puts "Entering condition '#{@sy}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{Condition.first.to_a} but saw '#{@sy.text}'",
          keys | Condition.follow | Condition.first | Expression.first)
    expr_node_1 = nil
    relop_node  = nil
    expr_node_2 = nil
    
    if Condition.first.include? @sy.text
      next_token
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
    return ConditionNode.new(expr_node_1, relop_node, expr_node_2) if expr_node_1 and relop_node and expr_node_2
    return ConditionNode.new(expr_node_1, nil, nil)
  end
  
  # <expression> -> <term> <expression-A>
  # <expression> -> <add-subop> <term> <expression-A>
=begin  def expression(keys)
    puts "Entering expression '#{@sy}'" if DEBUG
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
    
    puts "Leaving expression '#{@sy}'" if DEBUG
    return ExpressionNode.new(term_node, expr_a_node) if expr_a_node
    return ExpressionNode.new(term_node, nil)
  end
=end
  def expression(keys)
    puts "Entering expression '#{@sy}'" if DEBUG
    left_node = term(keys | Expression.follow)
    
    while @sy.type == TokenType::PLUS_TOKEN or @sy.type == TokenType::MINUS_TOKEN
      next_token
      left_node = AddSubOpNode.new(@sy.text, left_node, term(keys | Expression.follow))
    end
    
    puts "Leaving  expression '#{@sy}'" if DEBUG
    return ExpressionNode.new(left_node)
  end
  
  def term(keys)
    puts "Entering term '#{@sy}'" if DEBUG
    left_node = factor(keys | Term.follow)
    
    while @sy.type == TokenType::MULT_TOKEN or @sy.type == TokenType::DIV_TOKEN
      next_token
      left_node = MultDivOpNode.new(@sy.text, left_node, factor(keys | Term.follow))
    end
    
    puts "Leaving  term '#{@sy}'" if DEBUG
    return TermNode.new(left_node)
  end
  
  # <expression-A> -> <add-subop> <term> <expression-A>
  # <expression-A> -> e
=begin  def expression_a(keys)
    puts "Entering expression_a '#{@sy}'" if DEBUG

    add_sub_node = nil
    term_node    = nil
    expr_a_node  = nil
    
    if AddSubOp.first.include? @sy.text
      add_sub_node = add_sub_op(keys | ExpressionA.follow | Term.first)
      term_node    = term(keys | ExpressionA.follow | ExpressionA.first)
      expr_a_node  = expression_a(keys | ExpressionA.follow)
    end
    
    puts "Leaving expression_a '#{@sy}'" if DEBUG
    return ExpressionANode.new(add_sub_node, term_node, expr_a_node) if add_sub_node and term_node and expr_a_node
    return ExpressionANode.new(add_sub_node, term_node, nil)         if add_sub_node and term_node
    return nil
  end
  
  # <term> -> <factor> <term-A>
  def term(keys)
    puts "Entering term '#{@sy}'" if DEBUG
    factor_node = nil
    term_a_node = nil
    
    factor_node = factor(keys | Term.follow | TermA.first)
    term_a_node = term_a(keys | Term.follow)
    
    puts "Leaving term '#{@sy.text}'"if DEBUG
    return TermNode.new(factor_node, term_a_node) if term_a_node
    return TermNode.new(factor_node, nil) 
  end
  
  # <term-A> -> <mult-divop> <factor> <term-A>
  # <term-A> -> e
  def term_a(keys)
    puts "Entering term_a '#{@sy}'" if DEBUG
    
    mult_div_node = nil
    factor_node   = nil
    term_a_node   = nil
    
    if MultDivOp.first.include? @sy.text
      mult_div_node = mult_div_op(keys | TermA.follow | Factor.first)
      factor_node   = factor(keys | TermA.follow | TermA.first)
      term_a_node   = term_a(keys | TermA.follow)
    end
    
    puts "Leaving term_a '#{@sy.text}'"if DEBUG
    return TermANode.new(mult_div_node, factor_node, term_a_node) if mult_div_node and factor_node and term_a_node
    return TermANode.new(mult_div_node, factor_node, nil)         if mult_div_node and factor_node
    return nil
  end
=end  
  # <factor> -> [ident]
  # <factor> -> [number]
  # <factor> -> '(' <expression> ')'
  def factor(keys)
    puts "Entering factor '#{@sy}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{Factor.first} but saw '#{@sy.text}'", keys | Factor.follow | Factor.first)
    val = nil
    
    if @sy.type == TokenType::IDENT_TOKEN
      ident_check(@sy)
      val = @sy.text
      next_token
    elsif @sy.type == TokenType::NUMERAL_TOKEN
      val = @sy.text
      next_token
    elsif @sy.type == TokenType::L_PAREN_TOKEN
      next_token
      val = expression(keys | Factor.follow | Set['('])
      if @sy.type == TokenType::R_PAREN_TOKEN
        next_token
      else
        error("Line #{@sy.line_number}: expected ')' but saw '#{@sy.text}'", keys | Factor.follow)
      end
    else
      error("Line #{@sy.line_number}: expected #{Factor.first.to_a} but saw '#{@sy.text}'", keys | Factor.follow)
    end
    
    puts "Leaving factor '#{@sy}'" if DEBUG
    return FactorNode.new(val)
  end
  
  # <add-subop> -> '+'
  # <add-subop> -> '-'
  def add_sub_op(keys)
    puts "Entering add_sub_op '#{@sy}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{AddSubOp.first.to_a} but saw '#{@sy.text}'",
          keys | AddSubOp.follow | AddSubOp.first)
    op = nil
    
    if @sy.type == TokenType::PLUS_TOKEN or @sy.type == TokenType::MINUS_TOKEN
      op = @sy.text
      next_token
    else
      error("Line #{@sy.line_number}: expected #{AddSubOp.first.to_a} but saw '#{@sy.text}'",
            keys | AddSubOp.follow)
    end
    
    puts "Leaving add_sub_op '#{@sy.text}" if DEBUG
    return AddSubOpNode.new(op)
  end
  
  # <mult-divop> -> '*' | '\'
  def mult_div_op(keys)
    puts "Entering mult_div_op '#{@sy}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{MultDivOp.first.to_a} but saw '#{@sy.text}'", keys | MultDivOp.follow | MultDivOp.first)
    op = nil
    
    if @sy.type == TokenType::MULT_TOKEN or @sy.type == TokenType::DIV_TOKEN
      op = @sy.text
      next_token
    else
      error("Line #{@sy.line_number}: expected #{MultDivOp.first.to_a} but saw '#{@sy.text}'", keys | MultDivOp.follow)
    end
    
    puts "Leaving mult_div_op '#{@sy.text}"if DEBUG
    return MultDivOpNode.new(op)
  end
  
  # <relop> -> '=' | '<>' | '<' | '>' | '<=' | '>='
  def relop(keys)
    puts "Entering relop '#{@sy}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{Relop.first.to_a} but saw '#{@sy.text}'",
          keys | Relop.follow | Relop.first)
    op = nil
    
    if @sy.type == TokenType::EQUALS_TOKEN      or @sy.type == TokenType::RELOP_NEQ_TOKEN or
       @sy.type == TokenType::RELOP_LT_TOKEN    or @sy.type == TokenType::RELOP_GT_TOKEN  or
       @sy.type == TokenType::RELOP_LT_EQ_TOKEN or @sy.type == TokenType::RELOP_GT_EQ_TOKEN 
       op = @sy.text
       next_token
    else
      error("Line #{@sy.line_number}: expected #{Relop.first.to_a} but saw '#{@sy.text}'",
            keys | Relop.follow)
    end
    
    puts "Leaving relop '#{@sy.text}" if DEBUG
    return RelOpNode.new(op)
  end
end
