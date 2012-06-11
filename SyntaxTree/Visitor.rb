#
# Visitor.rb
#
# This class contains the interface that all subclasses can 
# optionally implement. Not all nodes in the AST will have information
# that is valuable
###########################################################
class Visitor
  def visit_program_node(program_node)  end
  def visit_block_node(block_node)      end
  def visit_declaration_node(decl_node) end
  def visit_const_declaration_node(const_decl_node) end
  def visit_const_list_node(const_list_node) end
end