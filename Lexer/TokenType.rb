#
# TokenType.rb
# Defines all the possible types of tokens that are 
# accepted by the compiler
#####################################################

class TokenType < Struct.new(:value, :name)  
    IDENT_TOKEN        = TokenType.new(0,  :IDENT_TOKEN)
    NUMERAL_TOKEN      = TokenType.new(1,  :NUMERAL_TOKEN)
    PROGRAM_TOKEN      = TokenType.new(2,  :PROGRAM_TOKEN)
    BEGIN_TOKEN        = TokenType.new(3,  :BEGIN_TOKEN)
    END_TOKEN          = TokenType.new(4,  :END_TOKEN)
    SEMI_COL_TOKEN     = TokenType.new(5,  :SEMI_COL_TOKEN)
    DECLARE_TOKEN      = TokenType.new(6,  :DECLARE_TOKEN)
    COMMA_TOKEN        = TokenType.new(7,  :COMMA_TOKEN)
    ASSIGN_TOKEN       = TokenType.new(8,  :ASSIGN_TOKEN)
    PERIOD_TOKEN       = TokenType.new(9,  :PERIOD_TOKEN)
    IF_TOKEN           = TokenType.new(10, :IF_TOKEN)
    THEN_TOKEN         = TokenType.new(11, :THEN_TOKEN)
    ELSE_TOKEN         = TokenType.new(12, :ELSE_TOKEN)
    END_IF_TOKEN       = TokenType.new(13, :END_IF_TOKEN)
    ODD_TOKEN          = TokenType.new(14, :ODD_TOKEN)
    COLON_TOKEN        = TokenType.new(15, :COLON_TOKEN)
    L_BRACE_TOKEN      = TokenType.new(16, :L_BRACE_TOKEN)
    R_BRACE_TOKEN      = TokenType.new(17, :R_BRACE_TOKEN)
    WHILE_TOKEN        = TokenType.new(18, :WHILE_TOKEN)
    LOOP_TOKEN         = TokenType.new(19, :LOOP_TOKEN)
    END_LOOP_TOKEN     = TokenType.new(20, :END_LOOP_TOKEN)
    INPUT_TOKEN        = TokenType.new(21, :INPUT_TOKEN)
    OUTPUT_TOKEN       = TokenType.new(22, :OUTPUT_TOKEN)
    PLUS_TOKEN         = TokenType.new(23, :PLUS_TOKEN)
    MINUS_TOKEN        = TokenType.new(24, :MINUS_TOKEN)
    MULT_TOKEN         = TokenType.new(25, :MULT_TOKEN)
    F_SLASH_TOKEN      = TokenType.new(26, :F_SLASH_TOKEN)
    L_PAREN_TOKEN      = TokenType.new(27, :L_PAREN_TOKEN)
    R_PAREN_TOKEN      = TokenType.new(28, :R_PAREN_TOKEN)
    #No 29 for some reason
    REAL_TOKEN         = TokenType.new(30, :REAL_TOKEN)
    INTEGER_TOKEN      = TokenType.new(31, :INTEGER_TOKEN)
    BOOLEAN_TOKEN      = TokenType.new(32, :BOOLEAN_TOKEN)
    EQUALS_TOKEN       = TokenType.new(33, :EQUALS_TOKEN)
    EOL_TOKEN          = TokenType.new(34, :EOL_TOKEN)
    EOF_TOKEN          = TokenType.new(35, :EOF_TOKEN)
    VAR_TOKEN          = TokenType.new(36, :VAR_TOKEN)
    CONST_TOKEN        = TokenType.new(37, :CONST_TOKEN)
    CALL_TOKEN         = TokenType.new(38, :CALL_TOKEN)
    PROCEDURE_TOKEN    = TokenType.new(39, :PROCEDURE_TOKEN)
    RELOP_NEQ_TOKEN    = TokenType.new(40, :RELOP_NEQ_TOKEN)
    RELOP_LT_TOKEN     = TokenType.new(41, :RELOP_LT_TOKEN)
    RELOP_GT_TOKEN     = TokenType.new(42, :RELOP_GT_TOKEN)
    RELOP_GT_EQ_TOKEN  = TokenType.new(43, :RELOP_GT_EQ_TOKEN)
    RELOP_LT_EQ_TOKEN  = TokenType.new(44, :RELOP_LT_EQ_TOKEN)
    DO_TOKEN           = TokenType.new(45, :DO_TOKEN)

  RESERVED_WORDS = 
  {
    "identifier"  => IDENT_TOKEN,
    "numeral"     => NUMERAL_TOKEN,
    "program"     => PROGRAM_TOKEN,
    "begin"       => BEGIN_TOKEN,
    "end"         => END_TOKEN,
    ";"           => SEMI_COL_TOKEN,
    "declare"     => DECLARE_TOKEN,
    ","           => COMMA_TOKEN,
    ":="          => ASSIGN_TOKEN,
    "."           => PERIOD_TOKEN,
    "if"          => IF_TOKEN,
    "then"        => THEN_TOKEN,
    "else"        => ELSE_TOKEN,
    "end_if"      => END_IF_TOKEN,
    "odd"         => ODD_TOKEN,
    "do"          => DO_TOKEN,
    ":"           => COLON_TOKEN,
    "{"           => L_BRACE_TOKEN,
    "}"           => R_BRACE_TOKEN,
    "while"       => WHILE_TOKEN,
    "loop"        => LOOP_TOKEN,
    "end_loop"    => END_LOOP_TOKEN,
    "input"       => INPUT_TOKEN,
    "output"      => OUTPUT_TOKEN,
    "+"           => PLUS_TOKEN,
    "-"           => MINUS_TOKEN,
    "*"           => MULT_TOKEN,
    "/"           => F_SLASH_TOKEN,
    "("           => L_PAREN_TOKEN,
    ")"           => R_PAREN_TOKEN,
    #No 29 for some reason
    "Real"        => REAL_TOKEN,
    "Integer"     => INTEGER_TOKEN,
    "Boolean"     => BOOLEAN_TOKEN,
    "="           => EQUALS_TOKEN,
    "EOL"         => EOL_TOKEN,
    "EOF"         => EOF_TOKEN,
    "var"         => VAR_TOKEN,
    "const"       => CONST_TOKEN,
    "call"        => CALL_TOKEN,
    "procedure"   => PROCEDURE_TOKEN,
    "<>"          => RELOP_NEQ_TOKEN,
    "<"           => RELOP_LT_TOKEN,
    ">"           => RELOP_GT_TOKEN,
    ">="          => RELOP_GT_EQ_TOKEN,
    "<="          => RELOP_LT_EQ_TOKEN
  }
end

