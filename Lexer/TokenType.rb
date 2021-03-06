#
# TokenType.rb
# Defines all the possible types of tokens that are
# accepted by the compiler
#####################################################
class TokenType < Struct.new(:value, :name)
  IDENT_TOKEN        = TokenType.new(1,  :IDENT_TOKEN)
  PROGRAM_TOKEN      = TokenType.new(2,  :PROGRAM_TOKEN)
  BEGIN_TOKEN        = TokenType.new(3,  :BEGIN_TOKEN)
  END_TOKEN          = TokenType.new(4,  :END_TOKEN)
  SEMI_COL_TOKEN     = TokenType.new(5,  :SEMI_COL_TOKEN)
  COMMA_TOKEN        = TokenType.new(6,  :COMMA_TOKEN)
  ASSIGN_TOKEN       = TokenType.new(7,  :ASSIGN_TOKEN)
  PERIOD_TOKEN       = TokenType.new(8,  :PERIOD_TOKEN)
  IF_TOKEN           = TokenType.new(9,  :IF_TOKEN)
  THEN_TOKEN         = TokenType.new(10, :THEN_TOKEN)
  ELSE_TOKEN         = TokenType.new(11, :ELSE_TOKEN)
  ODD_TOKEN          = TokenType.new(12, :ODD_TOKEN)
  COLON_TOKEN        = TokenType.new(13, :COLON_TOKEN)
  RETURN_TOKEN       = TokenType.new(14, :RETURN_TOKEN)
  WHILE_TOKEN        = TokenType.new(15, :WHILE_TOKEN)
  PLUS_TOKEN         = TokenType.new(16, :PLUS_TOKEN)
  MINUS_TOKEN        = TokenType.new(17, :MINUS_TOKEN)
  MULT_TOKEN         = TokenType.new(18, :MULT_TOKEN)
  DIV_TOKEN          = TokenType.new(19, :DIV_TOKEN)
  L_PAREN_TOKEN      = TokenType.new(20, :L_PAREN_TOKEN)
  R_PAREN_TOKEN      = TokenType.new(21, :R_PAREN_TOKEN)
  REAL_TOKEN         = TokenType.new(22, :REAL_TOKEN)
  INTEGER_TOKEN      = TokenType.new(23, :INTEGER_TOKEN)
  BOOLEAN_TOKEN      = TokenType.new(24, :BOOLEAN_TOKEN)
  EQUALS_TOKEN       = TokenType.new(25, :EQUALS_TOKEN)
  EOL_TOKEN          = TokenType.new(26, :EOL_TOKEN)
  EOF_TOKEN          = TokenType.new(27, :EOF_TOKEN)
  VAR_TOKEN          = TokenType.new(28, :VAR_TOKEN)
  CONST_TOKEN        = TokenType.new(29, :CONST_TOKEN)
  CALL_TOKEN         = TokenType.new(30, :CALL_TOKEN)
  FUNCTION_TOKEN     = TokenType.new(31, :FUNCTION_TOKEN)
  RELOP_NEQ_TOKEN    = TokenType.new(32, :RELOP_NEQ_TOKEN)
  RELOP_LT_TOKEN     = TokenType.new(33, :RELOP_LT_TOKEN)
  RELOP_GT_TOKEN     = TokenType.new(34, :RELOP_GT_TOKEN)
  RELOP_GT_EQ_TOKEN  = TokenType.new(35, :RELOP_GT_EQ_TOKEN)
  RELOP_LT_EQ_TOKEN  = TokenType.new(36, :RELOP_LT_EQ_TOKEN)
  DO_TOKEN           = TokenType.new(37, :DO_TOKEN)
  PRINT_TOKEN        = TokenType.new(38, :PRINT_TOKEN)
  READ_TOKEN         = TokenType.new(39, :READ_TOKEN)
  ARRAY_TOKEN        = TokenType.new(40, :ARRAY_TOKEN)
  OF_TOKEN           = TokenType.new(41, :OF_TOKEN)
  L_BRACKET_TOKEN    = TokenType.new(42, :L_BRACKET_TOKEN)
  R_BRACKET_TOKEN    = TokenType.new(43, :R_BRACKET_TOKEN)
  FOR_TOKEN          = TokenType.new(44, :FOR_TOKEN)
  ARROW_TOKEN        = TokenType.new(45, :ARROW_TOKEN)
  STRING_TOKEN       = TokenType.new(46, :STRING_TOKEN)
  COMMENT_TOKEN      = TokenType.new(47, :COMMENT_TOKEN)
  TRUE_TOKEN         = TokenType.new(48, :TRUE_TOKEN)
  FALSE_TOKEN        = TokenType.new(49, :FALSE_TOKEN)
  IN_TOKEN           = TokenType.new(50, :IN_TOKEN)
  RANGE_TOKEN        = TokenType.new(51, :RANGE_TOKEN)
  AND_TOKEN          = TokenType.new(52, :AND_TOKEN)
  OR_TOKEN           = TokenType.new(53, :OR_TOKEN)
  NOT_TOKEN          = TokenType.new(54, :NOT_TOKEN)
  LENGTH_TOKEN       = TokenType.new(55, :LENGTH_TOKEN)
  VOID_TOKEN         = TokenType.new(56, :VOID_TOKEN)
  REM_TOKEN          = TokenType.new(57, :REM_TOKEN)
  
  # map of reserved words and their internal values
  RESERVED_WORDS =
  {
    "identifier"     => IDENT_TOKEN,
    "program"        => PROGRAM_TOKEN,
    "begin"          => BEGIN_TOKEN,
    "end"            => END_TOKEN,
    ";"              => SEMI_COL_TOKEN,
    ","              => COMMA_TOKEN,
    "="              => ASSIGN_TOKEN,
    "if"             => IF_TOKEN,
    "then"           => THEN_TOKEN,
    "else"           => ELSE_TOKEN,
    "odd"            => ODD_TOKEN,
    "do"             => DO_TOKEN,
    ":"              => COLON_TOKEN,
    "while"          => WHILE_TOKEN,
    "+"              => PLUS_TOKEN,
    "-"              => MINUS_TOKEN,
    "*"              => MULT_TOKEN,
    "/"              => DIV_TOKEN,
    "("              => L_PAREN_TOKEN,
    ")"              => R_PAREN_TOKEN,
    "integer"        => INTEGER_TOKEN,
    "boolean"        => BOOLEAN_TOKEN,
    "string"         => STRING_TOKEN,
    "void"           => VOID_TOKEN,
    "=="             => EQUALS_TOKEN,
    "EOL"            => EOL_TOKEN,
    "EOF"            => EOF_TOKEN,
    "var"            => VAR_TOKEN,
    "const"          => CONST_TOKEN,
    "call"           => CALL_TOKEN,
    "function"       => FUNCTION_TOKEN,
    "!="             => RELOP_NEQ_TOKEN,
    "<"              => RELOP_LT_TOKEN,
    ">"              => RELOP_GT_TOKEN,
    ">="             => RELOP_GT_EQ_TOKEN,
    "<="             => RELOP_LT_EQ_TOKEN,
    "print"          => PRINT_TOKEN,
    "read"           => READ_TOKEN,
    "return"         => RETURN_TOKEN,
    "array"          => ARRAY_TOKEN,
    "of"             => OF_TOKEN,
    "["              => L_BRACKET_TOKEN,
    "]"              => R_BRACKET_TOKEN,
    "for"            => FOR_TOKEN,
    '->'             => ARROW_TOKEN,
    "%"              => COMMENT_TOKEN,
    "true"           => TRUE_TOKEN,
    "false"          => FALSE_TOKEN,
    "in"             => IN_TOKEN,
    ".."             => RANGE_TOKEN,
    '&&'             => AND_TOKEN,
    '||'             => OR_TOKEN,
    '!'              => NOT_TOKEN,
    '#'              => LENGTH_TOKEN,
    '%'              => REM_TOKEN
  }
end

