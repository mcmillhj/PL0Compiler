require_relative '../Lexer/SymbolTable.rb'
require_relative 'Visitor.rb'
class SemanticCheckVisitor < Visitor
  def initialize()
    @sym_table = SymbolTable.instance
    @name      = "unknown"
    @procs     = []
    @vars      = []
  end

  # Make sure that the program is semantically correct
  def check(root)
    # use the visitor pattern to evaluate the AST nodes
    root.accept(self)
  end

  #####################################
  # visitor methods
  #####################################
  def visit_program_node(program_node)
    @name = program_node.name
  end

  def visit_block_node(block_node)

  end

  def visit_declaration_node(decl_node)

  end

  def visit_const_declaration_node(const_decl_node) 
  
  end

  def visit_const_list_node(const_list_node)        
  
  end

  def visit_const_a_node(const_a_node)              
  end

  def visit_var_decl_node(var_decl_node)            
  end

  def visit_identifier_list_node(ident_list_node)   
  end

  def visit_identifier_a_node(id_a_node)            
  end

  def visit_procedure_decl_node(proc_decl_node)     
  end

  def visit_procedure_a_node(proc_a_node)           
  end

  def visit_type_node(type_node)                    
  end

  def visit_statement_node(statement_node)          
  end

  def visit_assign_statement_node(a_state_node)     
  end

  def visit_call_statement_node(call_state_node)    
  end

  def visit_begin_statement_node(b_state_node)      
  end

  def visit_if_statement_node(if_state_node)        
  end

  def visit_if_statement_a_node(if_state_node)      
  end

  def visit_while_statement_node(while_state_node)  
  end

  def visit_print_statement_node(pr_state_node)     
  end

  def visit_read_statement_node(read_state_node)    
  end

  def visit_statement_list_node(state_list_node)    
  end

  def visit_statement_a_node(state_a_node)          
  end

  def visit_condition_node(condition_node)         
  end

  def visit_expression_node(expression_node)        
  end

  def visit_expression_a_node(expression_a_node)    
  end

  def visit_term_node(term_node)                    
  end

  def visit_term_a_node(term_a_node)                
  end

  def visit_factor_node(factor_node)                
  end

  def visit_string_literal_node(str_literal_node)   
  end

  def visit_add_sub_op_node(add_sub_op_node)        
  end

  def visit_mult_div_op_node(mult_div_op_node)     
  end

  def visit_rel_op_node(rel_op_node)                
  end
  
  def visit_param_list_node(plist_node)
  end
end