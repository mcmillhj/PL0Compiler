#
# TokenType.rb
# Defines all the possible types of tokens that are 
# accepted by the compiler
#####################################################

class TokenType < Struct.new(:value, :type)
  RESERVED_WORDS = 
  {
    "identifier"  => TokenType.new(0,  :IDENT_TOKEN),
    "numeral"     => TokenType.new(1,  :NUMERAL_TOKEN),
    "program"     => TokenType.new(2,  :PROGRAM_TOKEN),
    "begin"       => TokenType.new(3,  :BEGIN_TOKEN),
    "end"         => TokenType.new(4,  :END_TOKEN),
    ";"           => TokenType.new(5,  :SEMI_COL_TOKEN),
    "declare"     => TokenType.new(6,  :DECLARE_TOKEN),
    ","           => TokenType.new(7,  :COMMA_TOKEN),
    ":="          => TokenType.new(8,  :ASSIGN_TOKEN),
    "."           => TokenType.new(9,  :PERIOD_TOKEN),
    "if"          => TokenType.new(10, :IF_TOKEN),
    "then"        => TokenType.new(11, :THEN_TOKEN),
    "else"        => TokenType.new(12, :ELSE_TOKEN),
    "end_if"      => TokenType.new(13, :END_IF_TOKEN),
    "odd"         => TokenType.new(14, :ODD_TOKEN),
    ":"           => TokenType.new(15, :COLON_TOKEN),
    "{"           => TokenType.new(16, :L_BRACE_TOKEN),
    "}"           => TokenType.new(17, :R_BRACE_TOKEN),
    "while"       => TokenType.new(18, :WHILE_TOKEN),
    "loop"        => TokenType.new(19, :LOOP_TOKEN),
    "end_loop"    => TokenType.new(20, :END_LOOP_TOKEN),
    "input"       => TokenType.new(21, :INPUT_TOKEN),
    "output"      => TokenType.new(22, :OUTPUT_TOKEN),
    "+"           => TokenType.new(23, :PLUS_TOKEN),
    "-"           => TokenType.new(24, :MINUS_TOKEN),
    "*"           => TokenType.new(25, :MULT_TOKEN),
    "/"           => TokenType.new(26, :F_SLASH_TOKEN),
    "("           => TokenType.new(27, :L_PAREN_TOKEN),
    ")"           => TokenType.new(28, :R_PAREN_TOKEN),
    #No 29 for some reason
    "Real"        => TokenType.new(30, :REAL_TOKEN),
    "Integer"     => TokenType.new(31, :INTEGER_TOKEN),
    "Boolean"     => TokenType.new(32, :BOOLEAN_TOKEN),
    "="           => TokenType.new(33, :EQUALS_TOKEN),
    "EOL"         => TokenType.new(34, :EOL_TOKEN),
    "EOF"         => TokenType.new(35, :EOF_TOKEN),
    "var"         => TokenType.new(36, :VAR_TOKEN),
    "const"       => TokenType.new(37, :CONST_TOKEN),
    "call"        => TokenType.new(38, :CALL_TOKEN),
    "procedure"   => TokenType.new(39, :PROCEDURE_TOKEN),
    "<>"          => TokenType.new(40, :RELOP_NEQ_TOKEN),
    "<"           => TokenType.new(41, :RELOP_LT_TOKEN),
    ">"           => TokenType.new(42, :RELOP_GT_TOKEN),
    ">="          => TokenType.new(43, :RELOP_GT_EQ_TOKEN),
    "<="          => TokenType.new(44, :RELOP_LT_EQ_TOKEN)
  }
end
