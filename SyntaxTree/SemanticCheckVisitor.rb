require_relative '../Lexer/SymbolTable.rb'
require_relative 'Visitor.rb'
class SemanticCheckVisitor < Visitor
  DEBUG = false

  def initialize
    @sym_table     = SymbolTable.instance
    @name          = "unknown"
    @functions     = {}
    @global_consts = []
    @global_vars   = []
    @local_vars    = Hash.new {|h,k| h[k] = []}
  end

  # Make sure that the program is semantically correct
  def check root 
    # use the visitor pattern to evaluate the AST nodes
    root.accept self
  end

  #####################################
  # visitor methods
  #####################################
  def visit_program_node program_node 
    puts "Visited Program Node" if DEBUG
    @name = program_node.name
  end

  def visit_block_node block_node 
    puts "Visited Block Node" if DEBUG
  end
  
  def visit_inner_block_node inner_block_node
    puts "Visited Inner Block Node" if DEBUG
    inner_block_node.type = inner_block_node.statement_node.type

  end

  def visit_declaration_node decl_node
    puts "Visited Declaration Node"  if DEBUG
  end
  
  def visit_inner_declaration_node inner_decl_node
    puts "Visited Inner Declaration Node"   if DEBUG
  end

  def visit_const_declaration_node const_decl_node
    puts "Visited Const Declaration Node"  if DEBUG
  end

  def visit_constant_list_node const_list_node 
    puts "Visited Const List Node" if DEBUG
    @global_consts = const_list_node.constant_list
  end

  def visit_constant_node const_node
    puts "Visited Constant Node" if DEBUG
    # determine type of constant
    type = const_node.val.type == TokenType::INTEGER_TOKEN ? 'integer' : 'string'
    
    # apply type 
    const_node.id.data_type = type
  end

  def visit_var_decl_node var_decl_node 
    puts "Visited Var Decl Node" if DEBUG
  end

  def visit_var_list_node var_list_node 
    puts "Visited Var list Node" if DEBUG
  end

  def visit_var_node var_node 
    puts "Visited Var Node" if DEBUG
    # save type of variable list
    type_node = var_node.type

    # reference to var_nodes list of identifiers
    ids = var_node.id_list.ids
    
    ids.each do |id|
      old = id
      id.data_type = type_node.type
      @sym_table.update(old, id)
      if id.scope == 'global'
        @global_vars << id
      else
        @local_vars[id.scope] << id.data_type
      end
    end
  end

  def visit_identifier_list_node ident_list_node 
    puts "Visited Id List Node" if DEBUG
  end

  def visit_function_decl_node function_decl_node
    puts "Visited Function Declaration Node" if DEBUG
  end
  
  def visit_function_list_node f_list_node
  end
  
  def visit_function_node function_node
    old = function_node.name
    function_node.name.ret_type  = function_node.ret_type.type
    function_node.name.data_type = "(#{function_node.param_list.types.join(' x ')}) => #{function_node.name.ret_type}" unless function_node.param_list.types.empty?
    function_node.name.data_type = "void => #{function_node.name.ret_type}" if function_node.param_list.types.empty?
    function_node.name.params    = function_node.param_list.types
    function_node.name.vars      = @local_vars[function_node.name.text]
    @sym_table.update(old, function_node.name)
    
    # save in function map
    @functions[function_node.name.text] = function_node
    
    if function_node.inner_block.type.nil? and function_node.name.ret_type != 'void'
      SemanticError.log("#{curr.name.text}: non-void function missing return statement (TypeError)") 
    elsif function_node.name.ret_type != function_node.inner_block.type
      SemanticError.log("#{curr.name.line_number}: function #{curr.name.text} of type '#{curr.name.data_type}' cannot return type '#{curr.inner_block.type}' (TypeError)")
    end
  end

  def visit_formal_param_list param_list 
    puts "Visited Formal Param List Node" if DEBUG
    param_list.type = param_list.types
  end

  def visit_actual_param_list param_list 
    puts "Visited Actual Param List Node" if DEBUG
    param_list.type = param_list.types
  end

  def visit_param_node param_node 
    puts "Visited Param Node" if DEBUG
    old = param_node.id
    param_node.id.data_type = param_node.type.type
    @sym_table.update(old, param_node.id)
  end

  def visit_type_node type_node 
    puts "Visited Type Node" if DEBUG
    type_node.type = type_node.type
  end

  def visit_array_node array_node 
    puts "Visited Array Node" if DEBUG
    array_node.type = "array of #{array_node.arr_type.type}"
  end

  # S..E => E > S
  def visit_range_node range_node 
    puts "Visited Range Node" if DEBUG
    return if range_node.end.is_a? FactorNode # ignore if taking the length of an array
    
    s, e = [range_node.start.text, range_node.end.text].map(&:to_i)
    if s > e
      SemanticError.log("#{range_node.start.line_number}: start value cannot be greater than end value (RangeError)")
    end
  end

  def visit_statement_node statement_node 
    puts "Visited Statement Node" if DEBUG
    statement_node.type = statement_node.statement_node.type if statement_node.statement_node
  end

  def visit_assign_statement_node a_state_node 
    puts "Visited Assign Statement Node" if DEBUG
    
    # save line # of operation
    line = a_state_node.id.line_number       if a_state_node.id.is_a? Token
    line = a_state_node.id.array.line_number if a_state_node.id.is_a? SelectorNode
    
    l = @sym_table.lookup(a_state_node.id)       if a_state_node.id.is_a? Token
    l = @sym_table.lookup(a_state_node.id.array) if a_state_node.id.is_a? SelectorNode
    r = a_state_node.expr.type
     
    # isolate return type
    if r =~ /=>/
      r = r.split("=>")[1].strip
    end
     
    if l.data_type != r
      puts "#{l} -- #{r}"
      SemanticError.log("#{line}: = is not defined for operands of type '#{l.data_type}' and '#{r}'")
    end 
    
    a_state_node.type = 'void'
  end

  def visit_call_statement_node call_state_node 
    puts "Visited Call Statement Node" if DEBUG
    call_state_node.type = @sym_table.lookup(call_state_node.name).data_type
    
    # get function being called and function type
    func_node = @functions[call_state_node.name.text]
    type      = @sym_table.lookup(func_node.name).data_type
    
    # make sure that function calls use the correct number and type of parameters
    if func_node.param_list.types != call_state_node.params.types
      SemanticError.log("#{call_state_node.name.line_number}: Function #{func_node.name.text} of type #{type} cannot be called with arguments (#{call_state_node.params.types.join(',')})")
    end
  end

  def visit_begin_statement_node b_state_node 
    puts "Visited Begin Statement Node" if DEBUG
    b_state_node.type = b_state_node.statement_list_node.type
  end

  def visit_if_statement_node if_state_node 
    puts "Visited If Statement Node" if DEBUG
    if if_state_node.expr_node.type == 'boolean'
      if if_state_node.if_statement_a_node
        l, r = if_state_node.statement_node.statement_node, if_state_node.if_statement_a_node.statement_node.statement_node
        
        if l.is_a? ReturnStatementNode and r.is_a? ReturnStatementNode
          if l.type != r.type 
            if_state_node.type = "#{l.type} | #{r.type}"
          else
            if_state_node.type = l.type
          end
        end
      end
    else
      SemanticError.log("If statements require 'boolean' expressions.")
    end
  end
  
  def visit_if_statement_a_node if_state_a_node 
    puts "Visited If Statement-A Node" if DEBUG
    if_state_a_node.type = if_state_a_node.statement_node.type if if_state_a_node and if_state_a_node.statement_node
  end

  def visit_while_statement_node while_state_node 
    puts "Visited While Statement Node" if DEBUG
    
    if while_state_node.expr.type == 'boolean'
      while_state_node.type = while_state_node.statement_node.type
    else
      SemanticError.log("While statements require 'boolean' expressions.")
    end
  end

  def visit_for_statement_node for_state_node 
    puts "Visited For Statement Node" if DEBUG
    for_state_node.type = for_state_node.state_node.type
  end

  def visit_print_statement_node pr_state_node 
    puts "Visited Print Statement Node" if DEBUG
    pr_state_node.type = 'void'
  end

  def visit_read_statement_node read_state_node 
    puts "Visited Read Statement Node" if DEBUG
    read_state_node.type = @sym_table.lookup(read_state_node.id).data_type
  end
  
  def visit_return_statement_node return_state_node
    puts "Visited Return Statement Node" if DEBUG
    return_state_node.type = 'void'
    return_state_node.type = return_state_node.expr_node.type if return_state_node.expr_node
  end

  def visit_statement_list_node state_list_node 
    puts "Visited Statement List Node" if DEBUG
    
    # default case
    state_list_node.type = 'void'
    
    if state_list_node
      # search through the list of statements and find the return statement
      # nil if missing
      state_list_node.state_list.each do |statement|
        state_list_node.type = statement.type if statement and statement.type != nil and statement.statement_node.is_a? ReturnStatementNode
      end
    end
  end

  def visit_expression_list_node expr_list_node 
    puts "Visited Expr List Node" if DEBUG
  end

  def visit_expression_node expression_node 
    puts "Visited Expr Node" if DEBUG
    expression_node.type = expression_node.expression.type
  end

  def visit_simple_expr_node simple_expr_node 
    puts "Visited Simple Expr Node" if DEBUG
    simple_expr_node.type = simple_expr_node.add_sub_node.type
  end

  # T<type> = MultDivOpNode<type> | Factor<type>
  def visit_term_node term_node 
    puts "Visited Term Node" if DEBUG
    term_node.type = term_node.value.type
  end

  def visit_factor_node factor_node 
    puts "Visited Factor Node" if DEBUG

    case factor_node.value.type      
    when TokenType::INTEGER_TOKEN
      factor_node.type = 'integer'
    when TokenType::STRING_TOKEN
      factor_node.type = 'string'
    when TokenType::TRUE_TOKEN    
      factor_node.type = 'boolean'
    when TokenType::FALSE_TOKEN
      factor_node.type = 'boolean'
    when TokenType::IDENT_TOKEN
      # grab type from symbol table and apply it to this factor node
      factor_node.type = @sym_table.lookup(factor_node.value).data_type
    else # handle FactorNodes that point to other nodes
      
      if factor_node.value.is_a? ExpressionNode or
         factor_node.value.is_a? CallStatementNode or
         factor_node.value.is_a? SelectorNode
        factor_node.type = factor_node.value.type
      elsif factor_node.is_a? LengthNode
        factor_node.type = 'integer'
      elsif factor_node.is_a? LogicalNegationNode
        factor_node.type = 'boolean'
      else 
        factor_node.type = 'void'
      end 
    end
  end

  # L + R  => L.type == R.type ^ L.type == 'integer' v L.type == 'string'
  # L - R  => L.type == R.type ^ L.type == 'integer'
  # L || R => L.type == R.type ^ L.type == 'boolean'
  # [+-||].type = L.type ^ R.type
  def visit_add_sub_op_node add_sub_op_node 
    puts "Visited Add Sub Op Node" if DEBUG
    
    op = add_sub_op_node.op
    l  = add_sub_op_node.left
    r  = add_sub_op_node.right
    
    # save line number
    line = l.value.value.line_number if l.value.value.is_a? Token
    line = r.value.value.line_number if r.value.value.is_a? Token


    # grab the most recent type information from the SymbolTable
    l = @sym_table.lookup(l.value) if l.value.type == TokenType::IDENT_TOKEN
    r = @sym_table.lookup(r.value) if r.value.type == TokenType::IDENT_TOKEN
    
    if l.is_a? TermNode and r.is_a? TermNode
      if l.type == r.type 
        if l.type == 'integer' or l.type == 'string'
          add_sub_op_node.type = l.type
        else
          SemanticError.log("#{line}: #{op} is not defined for operands of type '#{l.type}'")
          add_sub_op_node.type = 'void'
        end
      elsif l.type != r.type
        SemanticError.log("#{line}: #{op} is not defined for operands of type '#{l.type}' and '#{r.type}' (TypeError)")
        add_sub_op_node.type = 'void'        
      else
        SemanticError.log("#{line}: #{op} cannot determine type of operands (TypeError)")
        add_sub_op_node.type = 'void'
      end
    end
  end

  # L [*/%] R => L.type == R.type ^ L.type == 'integer'
  # L && R    => L.type == R.type ^ L.type == 'boolean'
  # [*/%].type = L.type ^ R.type 
  # &&.type    = L.type ^ R.type
  def visit_mult_div_op_node mult_div_op_node 
    puts "Visited Mult Div Op Node" if DEBUG
    
    op = mult_div_op_node.op
    l  = mult_div_op_node.left
    r  = mult_div_op_node.right
    
    # save line number
    line = l.value.line_number if l.value.is_a? Token
    line = r.value.line_number if r.value.is_a? Token

    # grab the most recent type information from the SymbolTable
    l = @sym_table.lookup(l.value) if l.value.type == TokenType::IDENT_TOKEN
    r = @sym_table.lookup(r.value) if r.value.type == TokenType::IDENT_TOKEN
    
    # check all combinations of operands and their types
    if l.is_a? Token and r.is_a? Token
      if l.data_type == r.data_type 
        if l.data_type == 'integer' or l.data_type == 'string'
          mult_div_op_node.type = l.data_type
        else
          SemanticError.log("#{line}: #{op} is not defined for operands of type '#{l.data_type}'")
          mult_div_op_node.type = 'void'
        end
      elsif l.data_type != r.data_type
        SemanticError.log("#{line}: #{op} is not defined for operands of type '#{l.data_type}' and '#{r.data_type}' (TypeError)")
        mult_div_op_node.type = 'void'        
      end
    elsif l.is_a? FactorNode and r.is_a? FactorNode
      if l.type == r.type 
        if l.type == 'integer' or l.type == 'string'
          mult_div_op_node.type = l.type
        else
          SemanticError.log("#{line}: #{op} is not defined for operands of type '#{l.type}'")
          mult_div_op_node = 'void'
        end
      elsif l.type != r.type
        SemanticError.log("#{line}: #{op} is not defined for operands of type '#{l.type}' and '#{r.type}' (TypeError)")
        mult_div_op_node.type = 'void'        
      end
    elsif l.is_a? Token and r.is_a? FactorNode
      if l.data_type == r.type 
        if l.data_type == 'integer' or l.data_type == 'string'
          mult_div_op_node.type = l.data_type
        else
          SemanticError.log("#{line}: #{op} is not defined for operands of type '#{l.data_type}'")
          mult_div_op_node.type = 'void'
        end
      elsif l.data_type != r.type
        SemanticError.log("#{line}: #{op} is not defined for operands of type '#{l.data_type}' and '#{r.type}' (TypeError)")
        mult_div_op_node.type = 'void'        
      end
    elsif l.is_a? FactorNode and r.is_a? Token
      if l.type == r.data_type 
        if l.type == 'integer' or l.type == 'string'
          mult_div_op_node.type = l.type
        else
          SemanticError.log("#{line}: #{op} is not defined for operands of type '#{l.type}'")
          mult_div_op_node.type = 'void'
        end
      elsif l.data_type != r.type
        SemanticError.log("#{line}: #{op} is not defined for operands of type '#{l.type}' and '#{r.type}' (TypeError)")
        mult_div_op_node.type = 'void'        
      end
    else
      SemanticError.log("#{line}: Cannot determine types of operands (TypeError)")
      mult_div_op_node.type = 'void'
    end
  end

  # RelopNode.type = 'boolean'
  def visit_relop_node rel_op_node 
    puts "Visited Rel Op Node" if DEBUG
    rel_op_node.type = 'boolean'
  end

  # SelectorNode.type = Array.type
  def visit_selector_node selector_node 
    puts "Visited Selector Node" if DEBUG
    
    selector_node.type = case @sym_table.lookup(selector_node.array).data_type
     when /.*integer.*/ 
       'integer'
     when /.*boolean.*/ 
       'boolean'
     when /.*string.*/  
       'string'
     end
  end
  
  # LengthNode.type = 'integer'
  def visit_length_node length_node
    puts "Visited Length Node" if DEBUG
    length_node.type = 'integer'
    
    # save line number of operation    
    line = length_node.ident.line_number
    
    # get current type information from the symbol table
    operand = @sym_table.lookup length_node.ident
    
    if operand.data_type != 'string' and !operand.data_type =~ '.*array.*'
      SemanticError.log("#{line}: # is not defined for operand of type '#{operand.data_type}'")
    end
  end
end