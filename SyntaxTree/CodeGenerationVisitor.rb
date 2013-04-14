require_relative '../Lexer/SymbolTable.rb'
require_relative 'Visitor.rb'

class CodeGenerationVisitor < Visitor
  DEBUG = false
  
  def initialize
    @symbol_table = SymbolTable.instance
    @name = nil
    # maps high level operators to their corresponding x86 instructions
    @ops    = {'+' => 'add', '-' => 'sub', '*' => 'imul', '/' => 'idiv', 
               '&&' => 'and', '||' => 'or', '%' => 'idiv', '!' => 'not',
               '=' => 'mov'}
    
    # maps high level types to their corresponding sizes in x86
    @types     = {'integer' => 'l', 'string' => 'l', 'boolean' => 'b'}
    @code      = { :global => [], :data => [], :rodata => [], :text => []}
    @functions = {}
    
    # current function environment, start with main
    @env       = {}
    @current   = 'main'
  end
  
  # store the instructions in the appropriate section of the program
  def emit(instr, section = :text)    
    @code[section] << instr
  end
  
  def generate(root, name)
    @name = name
    emit ".file \"#{@name}.sy\"", :global
    root.accept self
    
    code_gen
  end
  
  def code_gen
    @code.each_entry do |k,v|
      puts ".section .#{k}" unless k == :global
      v.map{|i| puts i}
      puts
    end
    
    @functions.each_entry do |k,v|
      puts "#{k} -> #{v.flatten}"
    end
  end
  
  #####################################
  # visitor methods
  #####################################
  def visit_program_node program_node 
    puts "Visited Program Node" if DEBUG
  end

  def visit_block_node block_node 
    puts "Visited Block Node" if DEBUG
  end
  
  def visit_inner_block_node inner_block_node
    puts "Visited Inner Block Node" if DEBUG
    inner_block_node.code << inner_block_node.inner_declaration_node.code if inner_block_node.inner_declaration_node.code
    inner_block_node.code << inner_block_node.statement_node.code         if inner_block_node.statement_node.code
  end

  def visit_declaration_node decl_node
    puts "Visited Declaration Node"  if DEBUG
  end
  
  def visit_inner_declaration_node inner_decl_node
    puts "Visited Inner Declaration Node"   if DEBUG
    inner_decl_node.code << inner_decl_node.var_decl_node.code if inner_decl_node.var_decl_node
  end

  def visit_const_declaration_node const_decl_node
    puts "Visited Const Declaration Node"  if DEBUG

  end

  def visit_constant_list_node const_list_node 
    puts "Visited Const List Node" if DEBUG
  end

  def visit_constant_node const_node
    puts "Visited Constant Node" if DEBUG
    
    emit "#{const_node.id.text}: ", :rodata
     
    if const_node.type == 'integer'
      emit ".long #{const_node.val.text}", :rodata
    else # string
      emit ".ascii \"#{const_node.val.text}\"", :rodata
    end
    
    # store in environment
    @env[const_node.id.text] = const_node.id.text
  end

  def visit_var_decl_node var_decl_node 
    puts "Visited Var Decl Node" if DEBUG
  end

  def visit_var_list_node var_list_node 
    puts "Visited Var list Node" if DEBUG
  end

  def visit_var_node var_node 
    puts "Visited Var Node" if DEBUG
    
    ids = var_node.id_list.ids
    
    ids.each do |id|
      if id.scope == 'global'
        # emit label
        emit "#{id.text}:", :data
        
        var = case id.data_type
        when 'integer'
          ".long 0"
        when 'string'
          ".ascii \"\0\""
        when 'boolean'
          ".long 0" # false
        when 'array of integer', 'array of string'
          len  = @symbol_table.lookup(id).length # get array length
          init = ("0 " * len).split.join(",") 
          ".long #{init}"
        when 'array of boolean'
          len  = @symbol_table.lookup(id).length # get array length
          init = ("0 " * len).split.join(",")
          ".long #{init}"
        end
        
        emit var, :data
        
        # store in environment
        @env[id.text] = id.text
      else
        # do nothing for now  
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
    puts "Visited Function List" if DEBUG
  end
  
  def visit_function_node function_node
    puts "Visited Function Node" if DEBUG
    name = function_node.name.text
    @functions[name] = []
    
    function_node.code = function_node.inner_block.code
    @functions[name] << function_node.code
  end

  def visit_formal_param_list param_list 
    puts "Visited Formal Param List Node" if DEBUG
  end

  def visit_actual_param_list param_list 
    puts "Visited Actual Param List Node" if DEBUG
  end

  def visit_param_node param_node 
    puts "Visited Param Node" if DEBUG
  end

  def visit_type_node type_node 
    puts "Visited Type Node" if DEBUG
  end

  def visit_array_node array_node 
    puts "Visited Array Node" if DEBUG
  end

  def visit_range_node range_node 
    puts "Visited Range Node" if DEBUG
  end

  def visit_statement_node statement_node 
    puts "Visited Statement Node" if DEBUG
    statement_node.code << statement_node.statement_node.code if statement_node.statement_node and statement_node.statement_node.code
  end

  def visit_assign_statement_node a_state_node 
    puts "Visited Assign Statement Node" if DEBUG
    
    node_type = a_state_node.expr.expression.add_sub_node
    op    = '='
    right = a_state_node.expr.code
    type  = a_state_node.type 
    dest  = a_state_node.id.text

    a_state_node.code << right
    a_state_node.code << "movl %eax, $#{dest}" if node_type.is_a? CallStatementNode
    a_state_node.code << "movl $#{right}, $#{dest}" if node_type.is_a? Token
    a_state_node.code << "movl (%esp), $#{dest}" if node_type.is_a? ExpressionNode
  end

  def visit_call_statement_node call_state_node 
    puts "Visited Call Statement Node" if DEBUG

    call_state_node.code << "pushl %ebp"

    call_state_node.params.expr_list.reverse_each do |e|
      call_state_node.code << e.code       if e.code
    end
    
    call_state_node.code << "call #{call_state_node.name.text}"
  end

  def visit_begin_statement_node b_state_node 
    puts "Visited Begin Statement Node" if DEBUG
    b_state_node.code << b_state_node.statement_list_node.code
  end

  def visit_if_statement_node if_state_node 
    puts "Visited If Statement Node" if DEBUG
  end
  
  def visit_if_statement_a_node if_state_a_node 
    puts "Visited If Statement-A Node" if DEBUG
  end

  def visit_while_statement_node while_state_node 
    puts "Visited While Statement Node" if DEBUG
  end

  def visit_for_statement_node for_state_node 
    puts "Visited For Statement Node" if DEBUG
  end

  def visit_print_statement_node pr_state_node 
    puts "Visited Print Statement Node" if DEBUG
  end

  def visit_read_statement_node read_state_node 
    puts "Visited Read Statement Node" if DEBUG
  end
  
  def visit_return_statement_node return_state_node
    puts "Visited Return Statement Node" if DEBUG
    #puts return_state_node

    return_state_node.code << return_state_node.expr_node.code if return_state_node.expr_node.code 
    return_state_node.code << "popl %eax" 
    return_state_node.code << "leave" 
    return_state_node.code << "ret"
  end

  def visit_statement_list_node state_list_node 
    puts "Visited Statement List Node" if DEBUG

    state_list_node.state_list.each do |s|
      state_list_node.code << s.code
    end
  end

  def visit_expression_list_node expr_list_node 
    puts "Visited Expr List Node" if DEBUG
  end

  def visit_expression_node expression_node 
    puts "Visited Expr Node" if DEBUG
   # puts expression_node
    puts "E1: #{expression_node.code.inspect}"
    expression_node.code = expression_node.expression.code
    puts "E2: #{expression_node.code.inspect}"
  end

  def visit_simple_expr_node simple_expr_node 
    puts "Visited Simple Expr Node" if DEBUG
    puts "S1: #{simple_expr_node.code.inspect}"
    simple_expr_node.code = simple_expr_node.add_sub_node.code
    puts "S2: #{simple_expr_node.code.inspect}"
  end

  def visit_term_node term_node 
    puts "Visited Term Node" if DEBUG
    puts "T1: ", term_node.code.inspect
    term_node.code = term_node.value.code
    puts "T2: ", term_node.code.inspect
  end

  def visit_factor_node factor_node 
    puts "Visited Factor Node" if DEBUG
    puts "F: ", factor_node.code.inspect
    
    case factor_node.value.type      
    when TokenType::INTEGER_TOKEN
      #puts "$#{factor_node.value.text}"
      factor_node.code << "pushl $#{factor_node.value.text}"
    when TokenType::STRING_TOKEN
      #puts "$#{factor_node.value.text}"
      factor_node.code << "pushl $#{factor_node.value.text}"
    when TokenType::TRUE_TOKEN    
      #puts "$#{factor_node.value.text}"
      factor_node.code << "pushl $#{factor_node.value.text}"
    when TokenType::FALSE_TOKEN
      #puts "$#{factor_node.value.text}"
      factor_node.code << "pushl $#{factor_node.value.text}"
    when TokenType::IDENT_TOKEN
      #puts "#{factor_node.value.text}"
      factor_node.code << "pushl $#{factor_node.value.text}"
    else # handle FactorNodes that point to other nodes
      case factor_node.class
      when ExpressionNode
        factor_node.code = factor_node.value.code
      when CallStatementNode
      when SelectorNode
      when LengthNode
      when LogicalNegationNode
      else
        # shouldn't be here
        puts "!!!!!! ELSE !!!!!!!!"
      end
    end
  end

  def visit_add_sub_op_node add_sub_op_node 
    puts "Visited Add Sub Op Node" if DEBUG
    op    = add_sub_op_node.op
    left  = add_sub_op_node.left
    right = add_sub_op_node.right
    type  = add_sub_op_node.type

    puts "1 +L: #{left.code.inspect}"
    puts "1 +R: #{right.code.inspect}"

    add_sub_op_node.code << right.code
    add_sub_op_node.code << left.code
    add_sub_op_node.code << "popl %ebx"
    add_sub_op_node.code << "popl %eax"
    add_sub_op_node.code << "#{@ops[op]}l %ebx, %eax"
    add_sub_op_node.code << "pushl %eax"
    

    puts "2 +L: #{left.code.inspect}"
    puts "2 +R: #{right.code.inspect}"
  end

  def visit_mult_div_op_node mult_div_op_node 
    puts "Visited Mult Div Op Node" if DEBUG
    op    = mult_div_op_node.op
    left  = mult_div_op_node.left
    right = mult_div_op_node.right
    type  = mult_div_op_node.type
    
    
    mult_div_op_node.code << right.code
    mult_div_op_node.code << left.code
    mult_div_op_node.code << "popl %ebx"
    mult_div_op_node.code << "popl %eax"
    mult_div_op_node.code << "#{@ops[op]}l %ebx, %eax"
    mult_div_op_node.code << "pushl %eax" if op != '%' # /, *
    mult_div_op_node.code << "pushl %edx" if op == '%' # remainder
  end

  def visit_relop_node rel_op_node 
    puts "Visited Rel Op Node" if DEBUG
  end

  def visit_selector_node selector_node 
    puts "Visited Selector Node" if DEBUG
  end
  
  def visit_length_node length_node
    puts "Visited Length Node" if DEBUG
  end
end