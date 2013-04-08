#
# Visitor.rb
#
# This class contains the interface that all subclasses can 
# optionally implement. Not all nodes in the AST will have information
# that is valuable
###########################################################
class Visitor
  def visit_program_node(program_node)              end
  def visit_block_node(block_node)                  end
  def visit_declaration_node(decl_node)             end
  def visit_const_declaration_node(const_decl_node) end
  def visit_const_list_node(const_list_node)        end
  def visit_constant_node(const_node)               end
  def visit_var_decl_node(var_decl_node)            end
  def visit_var_list_node(var_list_node)            end
  def visit_var_node(var_node)                      end
  def visit_identifier_list_node(ident_list_node)   end
  def visit_function_decl_node(proc_decl_node)      end
  def visit_formal_param_list(param_list)           end
  def visit_actual_param_list(param_list)           end
  def visit_param_node(param_node)                  end
  def visit_type_node(type_node)                    end
  def visit_array_node(array_node)                  end
  def visit_range_node(range_node)                  end
  def visit_statement_node(statement_node)          end
  def visit_assign_statement_node(a_state_node)     end
  def visit_call_statement_node(call_state_node)    end
  def visit_begin_statement_node(b_state_node)      end
  def visit_if_statement_node(if_state_node)        end
  def visit_while_statement_node(while_state_node)  end
  def visit_for_statement_node(for_state_node)      end
  def visit_print_statement_node(pr_state_node)     end
  def visit_read_statement_node(read_state_node)    end
  def visit_statement_list_node(state_list_node)    end
  def visit_expression_list_node(expr_list_node)    end
  def visit_expression_node(expression_node)        end
  def visit_simple_expr_node(simple_expr_node)      end
  def visit_term_node(term_node)                    end
  def visit_factor_node(factor_node)                end
  def visit_add_sub_op_node(add_sub_op_node)        end
  def visit_mult_div_op_node(mult_div_op_node)      end
  def visit_rel_op_node(rel_op_node)                end
  def visit_selector_node(selector_node)            end  
  def visit_length_node(length_node)                end
end