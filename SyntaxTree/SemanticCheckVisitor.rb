require_relative '../Lexer/SymbolTable.rb'
require_relative 'Visitor.rb'
class SemanticCheckVisitor < Visitor
  DEBUG = false
  def initialize
    @sym_table     = SymbolTable.instance
    @name          = "unknown"
    @functions     = Set[]
    @global_consts = []
    @local_consts  = []
    @global_vars   = []
    @local_vars    = []
  end

  # Make sure that the program is semantically correct
  def check root 
    # use the visitor pattern to evaluate the AST nodes
    root.accept(self, :post)
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
  end

  def visit_constant_node const_node
    puts "Visited Constant Node" if DEBUG
    # determine type of constant
    type = const_node.val.type == TokenType::INTEGER_TOKEN ? 'integer' : 'string'
    # apply type 
    const_node.id.data_type = type
    
    # store constant in a list for record keeping
    if const_node.id.scope == EXTERNAL
      @global_consts << const_node.id
    else
      @local_consts  << const_node.id
    end 
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
    curr = var_node.id_list

    # mark type information in all identifiers
    while curr
      old = curr.id
      curr.id.data_type = type_node.type
      @sym_table.update(old, curr.id) # update the type in the SymbolTable
      curr = curr.id_list             # move to next element
    end
  end

  def visit_identifier_list_node ident_list_node 
    puts "Visited Id List Node" if DEBUG
  end

  def visit_function_decl_node function_decl_node
    puts "Visited Func Decl Node"      if DEBUG

    # iterate through all functions and enforce type rules
    # return types must match what is actually returned
    curr = function_decl_node
    while curr
      @functions << curr.name
      old = curr.name
      curr.name.ret_type = curr.ret_type.type
      @sym_table.update(old, curr.name)
      curr = curr.func_decl
    end
    
    function_decl_node.type = 'void'
  end

  def visit_formal_param_list param_list 
    puts "Visited Formal Param List Node" if DEBUG
  end

  def visit_actual_param_list param_list 
    puts "Visited Actual Param List Node" if DEBUG
  end

  def visit_param_node param_node 
    puts "Visited Param Node" if DEBUG
    old = param_node.id
    param_node.id.data_type = param_node.type.type
    @sym_table.update(old, param_node.id)
  end

  def visit_type_node type_node 
    puts "Visited Type Node" if DEBUG
  end

  def visit_array_node array_node 
    puts "Visited Array Node" if DEBUG
  end

  # make sure that endval > startval
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
  end

  def visit_assign_statement_node a_state_node 
    puts "Visited Assign Statement Node" if DEBUG
    
    
  end

  def visit_call_statement_node call_state_node 
    puts "Visited Call Statement Node" if DEBUG
  end

  def visit_begin_statement_node b_state_node 
    puts "Visited Begin Statement Node" if DEBUG
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

  def visit_statement_list_node state_list_node 
    puts "Visited Statement List Node" if DEBUG
  end

  def visit_expression_list_node expr_list_node 
    puts "Visited Expr List Node" if DEBUG
  end

  def visit_expression_node expression_node 
    puts "Visited Expr Node" if DEBUG
  end

  def visit_simple_expr_node simple_expr_node 
    puts "Visited Simple Expr Node" if DEBUG
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
    when TokenType::FALSE_TOKEN
      factor_node.type = 'boolean'
    when TokenType::IDENT_TOKEN
      # grab type from symbol table and apply it to this factor node
      factor_node.type = @sym_table.lookup(factor_node.value).data_type
    when nil # handle FactorNodes that point to other nodes
      case factor_node.value
      when ExpressionNode
      when CallStatementNode
      when SelectorNode
        factor_node.type = factor_node.value.type
      when LengthNode
        factor_node.type = 'integer'
      when LogicalNegationNode
        factor_node.type = 'boolean'
      end
    end
  end

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
          add_sub_op_node = 'void'
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
    
    if l.is_a? Token and r.is_a? Token
      SemanticError.log("#{line}: #{op} requires operands with matching types (TypeError)") if l.data_type != r.data_type
      mult_div_op_node.type = l.data_type
    elsif l.is_a? FactorNode and r.is_a? FactorNode
      SemanticError.log("#{line}: #{op} requires operands with matching types (TypeError)") if l.type != r.type
      mult_div_op_node.type = l.type
    elsif l.is_a? Token and r.is_a? FactorNode
      SemanticError.log("#{line}: #{op} requires operands with matching types (TypeError)") if l.data_type != r.type
      mult_div_op_node.type = l.data_type
    elsif l.is_a? FactorNode and r.is_a? Token
      SemanticError.log("#{line}: #{op} requires operands with matching types (TypeError)") if l.type != r.type
      mult_div_op_node.type = l.type
    else
      SemanticError.log("#{line}: Cannot determine types of operands (TypeError)")
      mult_div_op_node.type = 'void'
    end
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