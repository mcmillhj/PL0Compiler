require 'set'
module Sets
 # global definitions
  EMPTY_SET = Set[""]
  IDENT     = 'identifier'
  NUMBER    = 'numeral'
  STRING    = 'string'
  BOOLEAN   = 'boolean'
  
  class Program
    def self.first;  Block.first | Block.follow end

    def self.follow; Set['EOF'] end
  end

  class Block
    def self.first;  Declaration.first | Statement.first | EMPTY_SET end

    def self.follow; Set['end', ';'] end
  end

  class Declaration
    def self.first;  ConstDecl.first | VarDecl.first | FuncDecl.first end

    def self.follow; Statement.first | Block.follow end
  end

  class ConstDecl
    def self.first;  Set['const']  | EMPTY_SET end

    def self.follow; VarDecl.first | FuncDecl.first | Declaration.follow end
  end

  class ConstList
    def self.first;  Set[IDENT] end

    def self.follow; Set[';'] end
  end

  class VarDecl
    def self.first;  Set['var']     | EMPTY_SET end

    def self.follow; FuncDecl.first | Declaration.follow end
  end
  
  class Var
    def self.first; EMPTY_SET end
    def self.follow; EMPTY_SET end
  end
  
  class VarList
    def self.first; EMPTY_SET end
    def self.follow; EMPTY_SET end
  end

  class IdentList
    def self.first;  Set[IDENT] end

    def self.follow; Set[':'] end
  end

  class FuncDecl
    def self.first;  EMPTY_SET end

    def self.follow; Declaration.follow end
  end

  class StatementList
    def self.first;  Statement.first  end

    def self.follow; Set['end'] end
  end

  class Statement
    def self.first;  Set[IDENT, 'return', 'read', 'print', 'call', 'begin', 'if', 'while', 'for'] | EMPTY_SET end

    def self.follow; Block.follow | StatementList.follow | Set['else'] end
  end

  class Type
    def self.first;  BaseType.first | Array.first end

    def self.follow; Set[';'] end
  end

  class Condition
    def self.first;  Set['odd'] | Expression.first end

    def self.follow; Set['then', 'do'] end
  end
  
  class Selector
    def self.first;  Set['['] end 
    
    def self.follow; end
  end

  class Expression
    def self.first;  Term.first | AddSubOp.first end

    def self.follow; Relop.first | Condition.follow | Statement.follow | Set[','] end
  end

  class Term
    def self.first;  Factor.first end

    def self.follow; Expression.follow end
  end

  class Factor
    def self.first;  Set[IDENT, NUMBER, BOOLEAN, STRING, '#', '(', 'call', ] end

    def self.follow; Term.follow end
  end

  class AddSubOp
    def self.first;  Set['+', '-'] end

    def self.follow; Term.first end
  end

  class MultDivOp
    def self.first;  Set['*', "/"] end

    def self.follow; Factor.first end
  end

  class Relop
    def self.first;  Set['==', '!=', '<', '>', '<=', '>='] end

    def self.follow; Expression.first end
  end
  
  class ExpressionList
    def self.first;  Expression.first end
    
    def self.follow; Statement.follow end
  end
  
  class ExpressionListA
    def self.first;  Set[','] | EMPTY_SET end
    
    def self.follow; ExpressionList.follow end
  end
  
  class ParameterList
    def self.first; Set['('] | EMPTY_SET end
    
    def self.follow; Set[':']            end
  end
  
  class ActualParameterList
    def self.first;  EMPTY_SET   end
    def self.follow; EMPTY_SET   end
  end
  
  class Array
    def self.first;  Set['array'] end
    def self.follow; Type.follow  end
  end
  
  class Range
    def self.first;  EMPTY_SET end
    def self.follow; EMPTY_SET end
  end
  
  class BooleanExpression
    def self.first;  EMPTY_SET end
    def self.follow; EMPTY_SET end
  end
  
  class BooleanAndOr
    def self.first;  Set['&&', '||'] end
    def self.follow; EMPTY_SET end
  end
  
  class BaseType
    def self.first;  Set['integer', 'boolean', 'string'] end
    def self.follow; EMPTY_SET end
  end
  
  class ParamType
    def self.first;  BaseType.first | Array.first end
    def self.follow; EMPTY_SET end
  end
end