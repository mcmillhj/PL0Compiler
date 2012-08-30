require 'set'
module Sets
 # global definitions
  EMPTY_SET = Set[""]
  IDENT     = 'identifier'
  NUMBER    = 'numeral'
  LITERAL   = 'string_literal'
  
  class Program
    def self.first;  Block.first | Block.follow end

    def self.follow; Set['EOF'] end
  end

  class Block
    def self.first;  Declaration.first | Statement.first | EMPTY_SET end

    def self.follow; Set['.', ';'] end
  end

  class Declaration
    def self.first;  ConstDecl.first | VarDecl.first | ProcDecl.first end

    def self.follow; Statement.first | Block.follow end
  end

  class ConstDecl
    def self.first;  Set['const']  | EMPTY_SET end

    def self.follow; VarDecl.first | ProcDecl.first | Declaration.follow end
  end

  class ConstList
    def self.first;  Set[IDENT] end

    def self.follow; Set[';'] end
  end

  class ConstA
    def self.first;  Set[';'] | EMPTY_SET end

    def self.follow; ConstList.follow end
  end

  class VarDecl
    def self.first;  Set['var']     | EMPTY_SET end

    def self.follow; ProcDecl.first | Declaration.follow end
  end

  class IdentList
    def self.first;  Set[IDENT] end

    def self.follow; Set[':'] end
  end

  class IdentA
    def self.first;  Set[';'] | EMPTY_SET end

    def self.follow; IdentList.follow end
  end

  class ProcDecl
    def self.first;  ProcA.first | EMPTY_SET end

    def self.follow; Declaration.follow end
  end

  class ProcA
    def self.first;  Set['procedure'] | EMPTY_SET end

    def self.follow; ProcDecl.follow end
  end

  class StatementList
    def self.first;  Statement.first | StatementA.first end

    def self.follow; Set['end'] end
  end

  class Statement
    def self.first;  Set[IDENT, 'read', 'print', 'call', 'begin', 'if', 'while'] | EMPTY_SET end

    def self.follow; Block.follow | StatementA.first | StatementList.follow | Set['else'] end
  end

  class StatementA
    def self.first;  Set[';'] | EMPTY_SET end

    def self.follow; StatementList.follow end
  end

  class Type
    def self.first;  Set['integer', 'boolean', 'string'] end

    def self.follow; Set[';'] end
  end

  class Condition
    def self.first;  Set['odd'] | Expression.first end

    def self.follow; Set['then', 'do'] end
  end

  class Expression
    def self.first;  Term.first | AddSubOp.first end

    def self.follow; Relop.first | Condition.follow | Statement.follow | Set[','] end
  end

  class ExpressionA
    def self.first;  AddSubOp.first | EMPTY_SET end

    def self.follow; Expression.follow end
  end

  class Term
    def self.first;  Factor.first end

    def self.follow; ExpressionA.first | ExpressionA.follow | Expression.follow end
  end

  class TermA
    def self.first;  MultDivOp.first | EMPTY_SET end

    def self.follow; Term.follow end
  end

  class Factor
    def self.first;  Set[IDENT, NUMBER, '(', LITERAL] end

    def self.follow; TermA.first | Term.follow end
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
    def self.first;  Set['=', '<>', '<', '>', '<=', '>='] end

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
end