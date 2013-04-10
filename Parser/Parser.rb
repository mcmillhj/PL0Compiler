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
    @sy            = Token.new(TokenType::VOID_TOKEN, -1, "EMPTY")
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
  def check_table token
    @symbol_table.insert(token) if !@symbol_table.contains token
  end
  
  # determines if the identifier 'sym' is valid in the current scope
  def ident_check sym
    valid, scope = @stack.search sym
    NamingError.log("Line #{sym.line_number}: No identifier '#{sym.text}' in current scope '#{@current_level}'") if !valid
    
    scope
  end
  
  # Skips input symbols until a symbol 
  # is found from which compilation may 
  # resume
  #
  # keys: a Set of strings containing all symbols 
  # from which compilation can resume
  def error(mesg, keys)
    ParserError.log mesg
    
    while not keys.include? @sy.text
      next_token
    end
  end

  # Checks to see if the current symbol
  # is a key symbol
  # This check is done before all branches
  def check(mesg, keys)    
    # special case, generalizes identifiers and numbers
    if @sy.type == TokenType::IDENT_TOKEN
      test = "identifier"
    elsif @sy.type == TokenType::INTEGER_TOKEN
      test = "integer"
    elsif @sy.type == TokenType::STRING_TOKEN
      test = "string"
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
    program_node = program Sets::EMPTY_SET 
    
    SyntaxTree.new program_node
  end
  
  # <program> -> 'program' <block> 'end'
  def program(keys)
    puts "Entering program '#{@sy}'" if DEBUG
    block_node   = nil
    program_name = nil
    
    next_token # move past the default token EMPTY

    if @sy.type == TokenType::PROGRAM_TOKEN
      next_token
      if @sy.type == TokenType::IDENT_TOKEN
        program_name = @sy.text # store the name of the program
        next_token
        block_node = block(keys | Program.follow)
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
    ProgramNode.new(program_name, block_node)
  end
  
  #                 e
  # <block> -> <declaration> <statement>
  def block(keys)
    puts "Entering block '#{@sy}'" if DEBUG
    
    decl_node  = declaration(keys | Block.follow)
    state_node = statement(keys | Block.follow)
    
    puts "Leaving block '#{@sy}'" if DEBUG
    BlockNode.new(decl_node, state_node)
  end
  
  def inner_block(keys)
    puts "Entering inner_block '#{@sy}'" if DEBUG
    
    inner_decl_node = inner_declaration(keys | InnerBlock.follow)
    state_node      = statement(keys | InnerBlock.follow)
    
    puts "Leaving  inner_block '#{@sy}'" if DEBUG
    InnerBlockNode.new(inner_decl_node, state_node)
  end
  
  #                       e           e           e
  # <declaration> -> <const-decl> <var-decl> <func-decl>
  def declaration(keys)
    puts "Entering declaration '#{@sy}'" if DEBUG
    
    const_decl_node = const_decl(keys | Declaration.follow | VariableDeclaration.first | FunctionDeclaration.first)
    var_decl_node   = var_decl(keys   | Declaration.follow | FunctionDeclaration.first)
    func_decl_node  = function_declaration(keys  | Declaration.follow)
    
    puts "Leaving declaration '#{@sy.text}" if DEBUG
    DeclarationNode.new(const_decl_node, var_decl_node, func_decl_node)
  end
  
  def inner_declaration(keys)
    puts "Entering inner_declaration '#{@sy}'" if DEBUG
    
    var_decl_node = var_decl(keys | InnerDeclaration.follow)
    
    puts "Entering inner_declaration '#{@sy}'" if DEBUG
    InnerDeclarationNode.new(var_decl_node)
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
      error("Line #{@sy.line_number}: Invalid base type #{@sy.text}", keys | BaseType.follow)
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
      error("Line #{@sy.line_number}: Invalid parameter type #{@sy.text}", keys | ParamType.follow)
    end
     
    puts "Leaving  param_type '#{@sy}'" if DEBUG
    return type if type.is_a? TypeNode
    TypeNode.new type
  end
  
  def return_type(keys)
    puts "Entering return_type '#{@sy}'" if DEBUG
    type = nil
    
    if ParamType.first.include? @sy.text
      type = param_type(keys | ReturnType.follow)  
    elsif @sy.type == TokenType::VOID_TOKEN
      type = @sy.text
      next_token
    else
      error("Line #{@sy.line_number}: Invalid return type #{@sy.text}", keys | ReturnType.follow)
    end
    
    puts "Leaving  return_type '#{@sy}'" if DEBUG
    return type if type.is_a? TypeNode
    TypeNode.new type
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
    return type if type.is_a? ArrayNode
    TypeNode.new type
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
    
    TypeNode.new "array of #{type.type}"
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
    ArrayNode.new(size, type)
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
    id   = nil
    expr = nil
    
    if @sy.type == TokenType::IDENT_TOKEN
      scope = ident_check(@sy)
      @sy.scope = scope
      id = @sy
      next_token
      
      if @sy.type == TokenType::L_BRACKET_TOKEN
        next_token
        if @sy.type == TokenType::IDENT_TOKEN or @sy.type == TokenType::INTEGER_TOKEN
          scope = ident_check @sy #if @sy.type == TokenType::IDENT_TOKEN
          @sy.scope = scope       #if @sy.type == TokenType::IDENT_TOKEN
          id = SelectorNode.new(id, @sy)
          next_token
          if @sy.type == TokenType::R_BRACKET_TOKEN
            next_token
          else
            error("Line #{@sy.line_number}: expected ']' but saw '#{@sy.text}'", keys | Factor.follow)
          end
        else
          error("Line #{@sy.line_number}: expected 'identifer' or 'integer' but saw '#{@sy.text}'", keys | Factor.follow)
        end
      end
      # check for assignment op
      if @sy.type == TokenType::ASSIGN_TOKEN
        next_token
        expr = expression(keys | Statement.follow)
      else
        error("Line #{@sy.line_number}: expected '=' but saw '#{@sy.text}'", keys | Statement.follow)
      end
    else
      error("#{sy.line_number}: expected 'identifier' but saw '#{@sy.txt}'", keys | Statement.follow)
    end
    
    puts "Leaving assignment_statement '#{@sy}'" if DEBUG
    AssignmentStatementNode.new(id, expr)
  end
  
  # TODO docs
  def expression_list(keys)
    puts "Entering expression_list '#{@sy}'" if DEBUG
    expr_list = []
    
    expr_list << expression(keys | ExpressionList.follow)
    while @sy.type == TokenType::COMMA_TOKEN
      next_token
      expr_list << expression(keys | ExpressionList.follow)
    end
    
    puts "Leaving expression_list '#{@sy}'" if DEBUG
    ExpressionListNode.new expr_list
  end
  
  # TODO docs
  def call_statement(keys)
    puts "Entering call_statement '#{@sy}'" if DEBUG
    name   = nil
    params = nil
    
    if @sy.type == TokenType::CALL_TOKEN
      next_token
      if @sy.type == TokenType::IDENT_TOKEN
        ident_check(@sy)
        @sy.scope = 'global'
        name = @sy
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
    CallStatementNode.new(name, params)
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
    expr            = nil
    statement       = nil
    if_statement_a  = nil
    
    if @sy.type == TokenType::IF_TOKEN
      next_token
      expr = expression(keys | Statement.follow | Set['then'])
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
    return IfStatementNode.new(expr, statement, if_statement_a)
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
    return nil unless statement_node
    IfStatementANode.new statement_node  
  end
  
  # TODO docs
  def while_statement(keys)
    puts "Entering while_statement '#{@sy}'" if DEBUG
         expr = nil
    statement = nil
    
    if @sy.type == TokenType::WHILE_TOKEN
      next_token
      expr = expression(keys | Set['do'] | Statement.follow)
      if @sy.type == TokenType::DO_TOKEN
        next_token
        statement = statement(keys | Statement.follow)
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
    return WhileStatementNode.new(expr, statement)  
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
    PrintStatementNode.new expr_list_node
  end
  
  # <read-statement> -> 'read' [ident]
  def read_statement(keys)
    puts "Entering read_statement '#{@sy}'" if DEBUG
    id = nil
    
    if @sy.type == TokenType::READ_TOKEN
      next_token
      if @sy.type == TokenType::IDENT_TOKEN
        scope = ident_check(@sy)
        @sy.scope = scope
        id = @sy
        next_token
      end
    else
      error("Line #{@sy.line_number}: expected 'read' but saw '#{@sy.text}'", keys | Statement.follow)
    end
    
     puts "Leaving read_statement '#{@sy}'" if DEBUG
    ReadStatementNode.new id
  end
  
  # <return-statement> -> 'return' <expression>
  # a procedure can return an expression or an identifier
  # the <expression> non-terminal can represent both of those
  def return_statement(keys)
    puts "Entering return_statement '#{@sy}'" if DEBUG
    
    if @sy.type == TokenType::RETURN_TOKEN
      next_token
      if @sy.type == TokenType::IDENT_TOKEN or @sy.type == TokenType::INTEGER_TOKEN or @sy.type == TokenType::STRING_TOKEN or 
         @sy.type == TokenType::TRUE_TOKEN or @sy.type == TokenType::FALSE_TOKEN
        expr_node = expression(keys | Statement.follow)
      end
    else
      error("Line #{@sy.line_number}: expected 'return' but saw '#{@sy.text}'", keys | Statement.follow)
    end
    
    puts "Leaving  return_statement '#{@sy}'" if DEBUG
    ReturnStatementNode.new expr_node
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
    
    if @sy.type == TokenType::INTEGER_TOKEN
      start = @sy
      next_token # move past start value
      if @sy.type == TokenType::RANGE_TOKEN
        next_token
        if @sy.type == TokenType::INTEGER_TOKEN
          end_val = @sy
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
    RangeNode.new(start, end_val)  
  end
  
  # <statement-list> -> <statement> <statement-A>
  def statement_list(keys)
    puts "Entering statement_list '#{@sy}'" if DEBUG
    state_list = []
    
    state_list << statement(keys | StatementList.follow)
    
    while @sy.type == TokenType::SEMI_COL_TOKEN
      next_token
      state_list << statement(keys | StatementList.follow)
    end
    
    puts "Leaving statement_list '#{@sy}'" if DEBUG
    StatementListNode.new state_list
  end
  
  # const-decl -> 'const' <const-list> ';'
  # const-decl -> e
  def const_decl(keys)
    puts "Entering const_decl '#{@sy}'" if DEBUG
    
    if @sy.type == TokenType::CONST_TOKEN
      next_token
      const_list_node = const_list(keys | ConstantDeclaration.follow)
      if @sy.type == TokenType::SEMI_COL_TOKEN
        next_token
      else
        error("Line #{@sy.line_number}: expected ';' but saw '#{@sy.text}'",keys | ConstantDeclaration.follow)
      end
    end
    
    puts "Leaving const_decl '#{@sy}'" if DEBUG
    ConstantDeclarationNode.new const_list_node
  end
  
  # <const-list> -> [ident] '=' [number], <const-A>
  def const_list(keys)
    puts "Entering const_list '#{@sy}'" if DEBUG
    const_list = []
    
    const_list << constant(keys | ConstantList.follow)
    while @sy.type == TokenType::COMMA_TOKEN
      next_token
      const_list << constant(keys | ConstantList.follow)
    end
    
    puts "Leaving const_list '#{@sy}" if DEBUG
    ConstantListNode.new const_list
  end
  
  def constant(keys)
    puts "Entering constant '#{@sy}'" if DEBUG
    id, val = nil, nil
    
    if @sy.type == TokenType::IDENT_TOKEN
      @stack.push @sy
      id = @sy
      
      if (s = @stack.get_current_scope) == EXTERNAL # check the current scope
        @sy.scope = EXTERNAL
      else # not global, local to some procedure
        @sy.scope = s
      end
        
      # make sure this symbol is in the SymbolTable
      check_table(@sy)
  
      if @current_level != s # update current scope if needed
         @current_level = s
      end
      
      next_token
      if @sy.type == TokenType::ASSIGN_TOKEN
        next_token
        if @sy.type == TokenType::INTEGER_TOKEN or @sy.type == TokenType::STRING_TOKEN
          val = @sy
          next_token
        else
          error("Line #{@sy.line_number}: expected 'integer' or 'string' but saw '#{@sy.text}'", keys | Constant.follow)
        end
      else
        error("Line #{@sy.line_number}: expected '=' but saw '#{@sy.text}'",keys | Constant.follow)
      end
    else
      error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'",keys | Constant.first)
    end
    
    puts "Leaving  constant '#{@sy}'" if DEBUG
    ConstantNode.new(id, val)
  end
  
  # <var-decl> -> 'var' <ident-list> ';'
  # <var-decl> -> e 
  def var_decl(keys)
    puts "Entering var_decl '#{@sy}'" if DEBUG
    var_list = nil
    
    if @sy.type == TokenType::VAR_TOKEN
      next_token
      var_list = var_list(keys | VariableDeclaration.follow)
      if @sy.type == TokenType::SEMI_COL_TOKEN
        next_token
      else
        error("Line #{@sy.line_number}: expected ';' but saw '#{@sy.text}'",keys | VariableDeclaration.follow)
      end
    end
    
    puts "Leaving var_decl '#{@sy.text}" if DEBUG
    VariableDeclarationNode.new var_list if var_list
  end

  def var_list(keys)
    puts "Entering var_list '#{@sy.text}" if DEBUG
    var_list = []
    
    var_list << var(keys | VariableList.follow)
      
    while @sy.type == TokenType::COMMA_TOKEN
      next_token
      var_list << var(keys | VariableList.follow)
    end

    puts "Leaving var_list '#{@sy.text}" if DEBUG
    VariableListNode.new var_list
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
    VarNode.new(id_list, type)
  end
  
  # <function-declaration> -> 'function' [ident] '(' <fpl> ')' '->' <type> <block> 'end' <func-decl>
  # <function-declaration> -> e 
  def function_declaration(keys)
    puts "Entering function_declaration '#{@sy}'" if DEBUG
    puts "Leaving  function_declaration '#{@sy}'" if DEBUG
    FunctionDeclarationNode.new function_list(keys | FunctionDeclaration.follow)
  end
  
  def function_list keys
    puts "Entering function_list '#{@sy}'" if DEBUG
    functions = []
    
    functions << function(keys | FunctionList.follow)
    while @sy.type == TokenType::FUNCTION_TOKEN
      functions << function(keys | FunctionList.follow)
    end
    
    puts "Leaving  function_list '#{@sy}'" if DEBUG
    FunctionListNode.new functions
  end
  
  def function keys
    puts "Entering function '#{@sy}'" if DEBUG
    
    if @sy.type == TokenType::FUNCTION_TOKEN
      next_token
      if @sy.type == TokenType::IDENT_TOKEN
        @stack.push @sy.text # push a new scope level onto the stack
        id = @sy # save function name
        
        # update token attributes in SymbolTable
        @sy.scope = EXTERNAL
        check_table(@sy) 
        
        # move past function name
        next_token
        fparam_list_node = formal_parameter_list(keys | Function.follow)
        
        if @sy.type == TokenType::ARROW_TOKEN
          next_token
          return_type_node = return_type(keys | Function.follow)
          inner_block_node = inner_block(keys | Function.follow)
          if @sy.type == TokenType::END_TOKEN
            @stack.pop_level # remove the most recent scope from the stack
            next_token
          else
            error("Line #{@sy.line_number}: expected 'end' but saw '#{@sy.text}'", keys | Function.follow | Set['end'])
          end
        else
          error("Line #{@sy.line_number}: expected '->' but saw '#{@sy.text}'", keys | Function.follow | Block.first)
        end
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'", keys  | Set['('])
      end
    end
    
    puts "Leaving function_declaration '#{@sy}'" if DEBUG
    
    FunctionNode.new(id, fparam_list_node, return_type_node, inner_block_node)
  end
  
  def formal_parameter_list(keys)
    puts "Entering parameter_list '#{@sy}'" if DEBUG
    param_list = []
    
    if @sy.type == TokenType::L_PAREN_TOKEN
      next_token
      param_list << param(keys | FormalParameterList.follow)
      
      while @sy.type == TokenType::COMMA_TOKEN
        next_token
        param_list << param(keys | FormalParameterList.follow)
      end
      
      if @sy.type == TokenType::R_PAREN_TOKEN
        next_token
      else
        error("Line #{@sy.line_number}: expected ')' but saw '#{@sy.text}'", keys | FormalParameterList.follow | Set['('])
      end
    end
    
    puts "Leaving parameter_list '#{@sy}'" if DEBUG
    ParameterListNode.new param_list
  end
  
  def actual_parameter_list(keys)
    puts "Entering actual_parameter_list '#{@sy}'" if DEBUG
    
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
    expr_list
  end
  
  def param(keys)
    puts "Entering param '#{@sy}'" if DEBUG
    id   = nil
    type = nil
    
    if @sy.type == TokenType::IDENT_TOKEN
        # return function information on this token object
        id            = @sy
        @sy.scope     = @stack.get_current_scope
        @stack.push @sy # push onto Name stack

        # make sure this token is in the SymbolTable
        check_table @sy
        next_token
        
        if @sy.type == TokenType::COLON_TOKEN
          next_token
          type = param_type(keys | FormalParameterList.follow)
        else
          error("Line #{@sy.line_number}: expected ':' but saw '#{@sy.text}'", keys | FormalParameterList.follow)
        end
      else
        error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'", keys | FormalParameterList.follow)
      end
      
    puts "Leaving  param '#{@sy}'" if DEBUG
    ParamNode.new(id, type)
  end
  
  # <ident-list> -> <ident> , <ident-list>
  def identifier_list(keys)
    puts "Entering identifier_list '#{@sy}'" if DEBUG
    ids = []
    ids << ident(keys | IdentifierList.follow)
    #if @sy.type == TokenType::COMMA_TOKEN
    #  next_token
    #  return IdentifierListNode.new(id, identifier_list(keys))
    #end
    while @sy.type == TokenType::COMMA_TOKEN
      next_token
      ids << ident(keys | IdentifierList.follow)
    end
    
    puts "Leaving identifier_list '#{@sy}'" if DEBUG
    #IdentifierListNode.new(id, nil)
    IdentifierListNode.new ids
  end
  
  def ident(keys)
    puts "Entering ident '#{@sy}" if DEBUG
    id = nil
    
    if @sy.type == TokenType::IDENT_TOKEN
      @stack.push @sy # push the token onto the stack
      id = @sy
      
      if (s = @stack.get_current_scope) == EXTERNAL # check the current scope
        @sy.scope = EXTERNAL
      else # not global, local to some procedure
        @sy.scope = s
      end
        
      check_table(@sy)
      
      if @current_level != s # update current scope if needed
         @current_level = s
      end
      
      next_token
    else
      error("Line #{@sy.line_number}: expected 'identifier' but saw '#{@sy.text}'",keys | IdentifierList.follow)  
    end
      
    puts "Leaving ident '#{@sy}" if DEBUG
    return id
  end
  
  def expression(keys)
    puts "Entering expression '#{@sy}'" if DEBUG

    expr = simple_expression(keys | Expression.follow)
    while Relop.first.include? @sy.text
      op = @sy.text
      next_token
      expr = RelationalOpNode.new(op, expr, simple_expression(keys | Expression.follow))
    end
    
    puts "Leaving  expression '#{@sy}'" if DEBUG
    ExpressionNode.new(expr)
  end
  
  # simple-expression -> <term> <add-subop> <term>
  def simple_expression(keys)
    puts "Entering simple_expression '#{@sy}'" if DEBUG
    
    left_node = term(keys | SimpleExpression.follow)
    
    while @sy.type == TokenType::PLUS_TOKEN or @sy.type == TokenType::MINUS_TOKEN or @sy.type == TokenType::OR_TOKEN
      op = @sy.text
      next_token
      left_node = AddSubOpNode.new(op, left_node, term(keys | SimpleExpression.follow))
    end
    
    puts "Leaving  simple_expression '#{@sy}'" if DEBUG
    SimpleExpressionNode.new left_node
  end
  
  # term -> <term> <mult-divop> <factor>
  def term(keys)
    puts "Entering term '#{@sy}'" if DEBUG
    left_node = factor(keys | Term.follow)
    
    while @sy.type == TokenType::MULT_TOKEN or @sy.type == TokenType::DIV_TOKEN or 
          @sy.type == TokenType::REM_TOKEN  or @sy.type == TokenType::AND_TOKEN 
      op = @sy.text
      next_token
      left_node = MultDivOpNode.new(op, left_node, factor(keys | Term.follow))
    end
    
    puts "Leaving  term '#{@sy}'" if DEBUG
    TermNode.new left_node
  end
  
  # <factor> -> [ident]
  # <factor> -> [number]
  # <factor> -> '(' <expression> ')'
  def factor(keys)
    puts "Entering factor '#{@sy}'" if DEBUG
    check("Line #{@sy.line_number}: expected #{Factor.first.to_a} but saw '#{@sy.text}'", keys | Factor.follow | Factor.first)
    val   = nil

    if @sy.type == TokenType::IDENT_TOKEN
      scope = ident_check @sy
      @sy.scope = scope
      val = @sy
      next_token
      if @sy.type == TokenType::L_BRACKET_TOKEN
        next_token
        if @sy.type == TokenType::IDENT_TOKEN or @sy.type == TokenType::INTEGER_TOKEN
          scope = ident_check @sy
          @sy.scope = scope
          val = SelectorNode.new(val, @sy)
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
    elsif @sy.type == TokenType::INTEGER_TOKEN or @sy.type == TokenType::TRUE_TOKEN or 
          @sy.type == TokenType::FALSE_TOKEN or @sy.type == TokenType::STRING_TOKEN
      @sy.scope = @stack.get_current_scope
      val = @sy
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
      scope = ident_check @sy
      @sy.scope = scope
      val = LengthNode.new @sy 
      next_token
    elsif @sy.type == TokenType::NOT_TOKEN
      next_token
      val = BooleanNotNode.new(factor(keys | Factor.follow))
    else
      error("Line #{@sy.line_number}: expected #{Factor.first.to_a} but saw '#{@sy.text}'", keys | Factor.follow)
    end
    
    puts "Leaving factor '#{@sy}'" if DEBUG
    FactorNode.new val
  end
  
  # <relop> -> '==' | '!=' | '<' | '>' | '<=' | '>='
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
