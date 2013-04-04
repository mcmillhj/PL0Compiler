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
  
  # determines if the identifier 'sym' is valid in the current scope
  def ident_check(sym)
    valid = @stack.search sym
    NamingError.log("Line #{sym.line_number}: No identifier '#{sym.text}' in current scope '#{@current_level}'") if !valid
    #NamingError.log("Line #{sym.line_number}: Identifier '#{sym.text}' already exists in current scope '#{@current_level}'") if valid and must_not_exist 
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
        error("Line #{@sy.line_number}: expected an identifier, but saw '#{@sy.text}'", keys | Program.follow)
      end
    else
      error("Line #{@sy.line_number}: expected a 'program', but saw '#{@sy.text}'", keys | Program.follow)
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
  
  # Basic type production
  # base-type -> 'integer' | 'boolean' | 'string'
  def base_type(keys)
    puts "Entering base_type '#{@sy}'" if DEBUG
    type = nil
    
    if BaseType.first.include? @sy.text
      type = @sy.text
      next_token
    else
      error("Invalid base_type #{@sy.text}", keys | BaseType.follow)
    end
    
    puts "Leaving  base_type '#{@sy}'" if DEBUG
    return TypeNode.new(type)
  end
  
  
  # param-type -> <base-type> | 'array' 'of' <type>
  # Type production used for formal parameters to functions
  def param_type(keys)
    puts "Entering param_type '#{@sy}'" if DEBUG
    type = nil
    
    if ParamType.first.include? @sy.text
      if @sy.type == TokenType::ARRAY_TOKEN
        type = param_array(keys | ParamType.follow)
      else
        type = @sy.text
        next_token
      end
    else
      error("Invalid param_type #{@sy.text}", keys | ParamType.follow)
    end
     
    puts "Leaving  param_type '#{@sy}'" if DEBUG
    return TypeNode.new(type)
  end
  
  # type -> <base-type> | <array>
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
  
  # <param-array> -> 'array' 'of' <type>
  # This array production is used for when arrays are parameters to functions
  def param_array(keys)
    puts "Entering param_array '#{@sy}'" if DEBUG
    type = nil
    
    if @sy.type == TokenType::ARRAY_TOKEN
      next_token
      if @sy.type == TokenType::OF_TOKEN
        next_token
        type = param_type(keys | Array.follow)
      else
        error("Line #{@sy.line_number} expected 'of', but saw '#{@sy.text}'", keys | Array.follow)
      end
    else
      error("Line #{@sy.line_number} expected 'array', but saw '#{@sy.text}'", keys | Array.follow)
    end
    puts "Leaving  param_array '#{@sy}'" if DEBUG
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
    
    return StatementNode.new(statement_node)
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
      error("Line #{@sy.line_number}: expected '=' but saw '#{@sy.text}'", keys | Statement.follow)
    end
    
    puts "Leaving assignment_statement '#{@sy}'" if DEBUG
    return AssignmentStatementNode.new(id_list_node, expr_list_node)
  end
  
  # TODO docs
  def expression_list(keys)
    puts "Entering expression_list '#{@sy}'" if DEBUG
    expr_list = nil
    
    expr_list = expression(keys | ExpressionList.follow)
    while @sy.type == TokenType::COMMA_TOKEN
      next_token
      expr_list = ExpressionListNode.new(expr_list, expression(keys | ExpressionList.follow))
    end
    
    puts "Leaving expression_list '#{@sy}'" if DEBUG
    return expr_list
  end
  
  # TODO docs
  def call_statement(keys)
    puts "Entering call_statement '#{@sy}'" if DEBUG
    name   = nil
    params = nil
    
    if @sy.type == TokenType::CALL_TOKEN
      next_token
      if @sy.type == TokenType::IDENT_TOKEN
        # make sure 
        ident_check(@sy)
        id = @sy.text
        next_token # grab the next token
        
        # process parameters
        params = actual_parameter_list(keys | Statement.follow)
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'", keys | Statement.follow)
      end
    else
      error("Line #{@sy.line_number}: expected 'call' but saw '#{@sy.text}'", keys | Statement.follow)
    end
    
    puts "Leaving call_statement '#{@sy}'" if DEBUG
    return CallStatementNode.new(name, params)
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
    bool_expr       = nil
    statement       = nil
    if_statement_a  = nil
    
    if @sy.type == TokenType::IF_TOKEN
      next_token
      bool_expr = boolean_expression(keys | BooleanExpression.follow | Statement.follow | Set['then'])
      if @sy.type == TokenType::THEN_TOKEN
        next_token
        statement      = statement(keys | Statement.follow)
        if_statement_a = if_statement_a(keys | Statement.follow)
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
    return IfStatementNode.new(bool_expr, statement, if_statement_a)
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
    return IfStatementANode.new(statement_node)  
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
    return WhileStatementNode.new(cond_node, statement_node)  
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
  
  # <read-statement> -> 'read' [ident]
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
  
  # <return-statement> -> 'return' <expression>
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
    id        = nil
    range     = nil
    statement = nil
    
    if @sy.type == TokenType::FOR_TOKEN
      next_token
      if @sy.type == TokenType::IDENT_TOKEN
        # make sure that no other variable with the same name as the
        # for loop counter exists
        ident_check(@sy)
        
        # temporarily place the counter in the SymbolTable
        check_table(@sy)
        
        id = @sy.text
        next_token
        if @sy.type == TokenType::IN_TOKEN
          next_token
          range = range(keys | Statement.follow)
          if @sy.type == TokenType::DO_TOKEN
            next_token
            statement = statement(keys | Statement.follow)
            if @sy.type == TokenType::END_TOKEN
              next_token
              # remove counter from SymbolTable
              
            else
              error("Line #{@sy.line_number}: expected 'end' but saw '#{@sy.text}'", keys | Statement.follow)
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
    return ForStatementNode.new(id, range, statement)
  end
  
  # range -> [integer]..[integer]
  def range(keys)
    puts "Entering range '#{@sy}'" if DEBUG  
    start   = nil
    end_val = nil
    
    if @sy.type == TokenType::NUMERAL_TOKEN
      start = @sy.text  
      next_token # move past start value
      if @sy.type == TokenType::RANGE_TOKEN
        next_token
        if @sy.type == TokenType::NUMERAL_TOKEN
          end_val = @sy.text
          next_token
        elsif @sy.type == TokenType::LENGTH_TOKEN
          end_val = factor(keys | Range.follow)
        else
          error("Line #{@sy.line_number}: expected #{['integer', 'ident']} but saw '#{@sy.text}'", keys | Range.follow)
        end
      else
        error("Line #{@sy.line_number}: expected '..' but saw '#{@sy.text}'", keys | Range.follow)
      end     
    else
      error("Line #{@sy.line_number}: expected 'integer' but saw '#{@sy.text}'", keys | Range.follow)
    end
    
    puts "Leaving  range '#{@sy}'" if DEBUG
    return RangeNode.new(start, end_val)  
  end
  
  # <statement-list> -> <statement> <statement-A>
  def statement_list(keys)
    puts "Entering statement_list '#{@sy}'" if DEBUG
    state_node   = nil
    state_a_node = nil
    
    state_node   = statement(keys   | StatementList.follow)
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
      state_node   = statement(keys)
      state_a_node = statement_a(keys)
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
    const      = nil
    const_list = nil
    
    const_list = constant(keys | ConstantList.follow)
    while @sy.type == TokenType::COMMA_TOKEN
      next_token
      const_list = ConstantListNode.new(const_list, constant(keys | ConstantList.follow))
    end
    
    puts "Leaving const_list '#{@sy.text}" if DEBUG
    return const_list
  end
  
  def constant(keys)
    puts "Entering constant '#{@sy.text}'" if DEBUG
    id, val = nil, nil
    
    if @sy.type == TokenType::IDENT_TOKEN
      @stack.push @sy
      id = @sy.text
      
      if (s = @stack.get_current_scope) == EXTERNAL # check the current scope
        @sy.scope = EXTERNAL
      else # not global, local to some procedure
        @sy.scope     = INTERNAL
        @sy.func_name = s
      end
        
      # make sure this symbol is in the SymbolTable
      check_table(@sy)
  
      if @current_level != s # update current scope if needed
         @current_level = s
      end
      
      next_token
      if @sy.type == TokenType::ASSIGN_TOKEN
        next_token
        if @sy.type == TokenType::NUMERAL_TOKEN or @sy.type == TokenType::STRING_TOKEN
          val = @sy.text
        else
          error("Line #{@sy.line_number}: expected 'numeral' or 'string' but saw '#{@sy.text}'",keys | Constant.follow)
        end
      else
        error("Line #{@sy.line_number}: expected '=' but saw '#{@sy.text}'",keys | Constant.follow)
      end
    else
      error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'",keys | ConstA.first)
    end
    
    puts "Leaving  constant '#{@sy.text}'" if DEBUG
    return ConstantNode.new(id, val)
  end
  
  # <var-decl> -> 'var' <ident-list> ';'
  # <var-decl> -> e 
  def var_decl(keys)
    puts "Entering var_decl '#{@sy}'" if DEBUG
    var_list = nil
    
    if @sy.type == TokenType::VAR_TOKEN
      next_token
      var_list = var_list(keys | VarDecl.follow)
      if @sy.type == TokenType::SEMI_COL_TOKEN
        next_token
      else
        error("Line #{@sy.line_number}: expected ';' but saw '#{@sy.text}'",keys | VarDecl.follow)
      end
    end
    
    puts "Leaving var_decl '#{@sy.text}" if DEBUG
    return VariableDeclarationNode.new(var_list)
  end

  def var_list(keys)
    puts "Entering var_list '#{@sy.text}" if DEBUG
    var_list = var(keys | VarList.follow)
      
    while @sy.type == TokenType::COMMA_TOKEN
      next_token
      var_list = VarListNode.new(var_list, var(keys | VarList.follow))
    end

    puts "Leaving var_list '#{@sy.text}" if DEBUG
    return var_list
  end

  def var(keys)
    puts "Entering var '#{@sy}'" if DEBUG
    id_list = nil
    type    = nil
    
    id_list = identifier_list(keys | Var.follow)

    if @sy.type == TokenType::COLON_TOKEN
      next_token
      type = type(keys | Var.follow)
    else
      error("Line #{@sy.line_number}: expected ':' but saw '#{@sy.text}'", keys | Var.follow)
    end
    
    puts "Leaving  var '#{@sy}'" if DEBUG
    return VarNode.new(id_list, type)
  end
  
  # <func-decl> -> 'function' [ident] '(' <fpl> ')' '->' <type> <block> 'end' <func-decl>
  # <func-decl> -> e 
  def func_decl(keys)
    puts "Entering func_a '#{@sy}'" if DEBUG
    id               = nil
    block_node       = nil
    func_node        = nil
    fparam_list_node = nil
    return_type_node = nil
    
    if @sy.type == TokenType::FUNCTION_TOKEN
      next_token
      if @sy.type == TokenType::IDENT_TOKEN
        @stack.push @sy.text # push a new scope level onto the stack
        id = @sy.text        # save function name
        
        # update token attributes in SymbolTable
        @sy.scope = EXTERNAL
        check_table(@sy) 
        
        # move past function name
        next_token
        
        fparam_list_node = formal_parameter_list(keys)
        if @sy.type == TokenType::ARROW_TOKEN
          next_token
          return_type_node = param_type(keys)
          block_node = block(keys)
          if @sy.type == TokenType::END_TOKEN
            @stack.pop_level # remove the most recent scope from the stack
            next_token
            func_node = func_decl(keys | FuncDecl.follow) # check for another procedure
          else
            error("Line #{@sy.line_number}: expected 'end' but saw '#{@sy.text}'", keys | Set['end'])
          end
        else
          error("Line #{@sy.line_number}: expected '->' but saw '#{@sy.text}'",keys | Block.first)
        end
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'", keys  | Set['('])
      end
    end
    
    puts "Leaving proc_a '#{@sy}'" if DEBUG
    return FunctionDeclarationNode.new(id, fparam_list_node, return_type_node, block_node, func_node)
  end
  
  def formal_parameter_list(keys)
    puts "Entering parameter_list '#{@sy}'" if DEBUG
    param_list = nil
    
    if @sy.type == TokenType::L_PAREN_TOKEN
      next_token
      param_list = param(keys | ParameterList.follow)
      
      while @sy.type == TokenType::COMMA_TOKEN
        next_token
        param_list = ParameterListNode.new(param_list, param(keys | ParameterList.follow))
      end
      
      if @sy.type == TokenType::R_PAREN_TOKEN
        next_token
      else
        error("Line #{@sy.line_number}: expected ')' but saw '#{@sy.text}'", keys | ParameterList.follow | Set['('])
      end
    end
    
    puts "Leaving parameter_list '#{@sy}'" if DEBUG
    return param_list
  end
  
  def actual_parameter_list(keys)
    puts "Entering actual_parameter_list '#{@sy}'" if DEBUG
    expr_list = nil
    
    if @sy.type == TokenType::L_PAREN_TOKEN
      next_token
      expr_list = expression_list(keys | ActualParameterList.follow)
      if @sy.type == TokenType::R_PAREN_TOKEN
        next_token
      else
        error("Line #{@sy.line_number}: expected ')' but saw '#{@sy.text}'", keys | ActualParameterList.follow)
      end
    end
    
    puts "Leaving  actual_parameter_list '#{@sy}'" if DEBUG
    return expr_list
  end
  
  def param(keys)
    puts "Entering param '#{@sy}'" if DEBUG
    id   = nil
    type = nil
    
    if @sy.type == TokenType::IDENT_TOKEN
      
        @stack.push @sy # push onto Name stack
        
        # return function information on this token object
        id            = @sy.text
        @sy.scope     = INTERNAL
        @sy.func_name = @stack.get_current_scope
        
        # make sure this token is in the SymbolTable
        check_table(@sy)
        
        next_token
        
        if @sy.type == TokenType::COLON_TOKEN
          next_token
          type = param_type(keys | ParameterList.follow)
        else
          error("Line #{@sy.line_number}: expected ':' but saw '#{@sy.text}'", keys | ParameterList.follow)
        end
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'", keys | ParameterList.follow)
      end
      
    puts "Leaving  param '#{@sy}'" if DEBUG
    return ParamNode.new(id, type)
  end
  
  # <ident-list> -> [ident] <ident-A>
  def identifier_list(keys)
    puts "Entering identifier_list '#{@sy}'" if DEBUG
    id_list = nil
    
    id_list = ident(keys | IdentList.follow)
    while @sy.type == TokenType::COMMA_TOKEN
      next_token
      id_list = IdentifierListNode.new(id_list, ident(keys | IdentList.follow))
    end
    
    puts "Leaving identifier_list '#{@sy}'" if DEBUG
    return IdentifierListNode.new(id_list, nil) if id_list.is_a? String
    return id_list
  end
  
  def ident(keys)
    puts "Entering ident '#{@sy}" if DEBUG
    id = nil
    
    if @sy.type == TokenType::IDENT_TOKEN
      @stack.push @sy # push the token onto the stack
      id = @sy.text
      
      if (s = @stack.get_current_scope) == EXTERNAL # check the current scope
        @sy.scope = EXTERNAL
      else # not global, local to some procedure
        @sy.scope     = INTERNAL
        @sy.func_name = s
      end
        
      check_table(@sy)
      
      if @current_level != s # update current scope if needed
         @current_level = s
      end
      
      next_token
    else
      error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'",keys | IdentList.follow)  
    end
      
    puts "Leaving ident '#{@sy}" if DEBUG
    return id
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
  
  def boolean_expression(keys)
    puts "Entering boolean_expression '#{@sy.text}" if DEBUG
    
    cond = condition(keys | BooleanExpression.follow)
    while @sy.type == TokenType::AND_TOKEN or @sy.type == TokenType::OR_TOKEN
      next_token
      cond = BooleanAndOrNode.new(@sy.text, cond, condition(keys | BooleanExpression.follow))
    end
     
    puts "Leaving  boolean_expression '#{@sy.text}" if DEBUG
    return BooleanExpressionNode.new(cond)
  end
  
  # expression -> <expression> <add-subop> <term>
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
  
  # term -> <term> <mult-divop> <factor>
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
  
  # <factor> -> [ident]
  # <factor> -> [number]
  # <factor> -> '(' <expression> ')'
  def factor(keys)
    puts "Entering factor '#{@sy}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{Factor.first.to_a} but saw '#{@sy.text}'", keys | Factor.follow | Factor.first)
    val   = nil
    
    if @sy.type == TokenType::IDENT_TOKEN
      ident_check(@sy)
      val = @sy.text
      next_token
      if @sy.type == TokenType::L_BRACKET_TOKEN
        next_token
        if @sy.type == TokenType::IDENT_TOKEN or @sy.type == TokenType::NUMERAL_TOKEN
          val = SelectorNode.new(val, @sy.text)
          next_token
          if @sy.type == TokenType::R_BRACKET_TOKEN
            next_token
          else
            error("Line #{@sy.line_number}: expected ']' but saw '#{@sy.text}'", keys | Factor.follow)
          end
        else
          error("Line #{@sy.line_number}: expected 'identifer' or 'numeral' but saw '#{@sy.text}'", keys | Factor.follow)
        end
      end
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
    elsif @sy.type == TokenType::CALL_TOKEN
      val = call_statement(keys | Factor.follow)
    elsif @sy.type == TokenType::LENGTH_TOKEN
      next_token
      val = LengthNode.new(@sy.text)
      next_token
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
