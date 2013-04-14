require 'set'
module Sets
 # global definitions
  EMPTY_SET = Set[]
  IDENT     = 'identifier'
  INTEGER   = 'integer'
  STRING    = 'string'
  TRUE      = 'true'
  FALSE     = 'false'
  BOOLEAN   = 'boolean'
  VOID      = 'void'
  
  class Program
    def self.first;  Set['program'] end
    def self.follow; Set['EOF'] end
  end

  class Block
    def self.first;  Declaration.first | Statement.first | EMPTY_SET end
    def self.follow; Set['end'] end
  end

  class InnerBlock
    def self.first;  InnerDeclaration.first | Statement.first | EMPTY_SET end
    def self.follow; Set['end']                                           end
  end

  class Declaration
    def self.first;  ConstantDeclaration.first | VariableDeclaration.first | FunctionDeclaration.first | EMPTY_SET end
    def self.follow; Statement.first | Block.follow end
  end
  
  class InnerDeclaration
    def self.first;  VariableDeclaration.first | EMPTY_SET end
    def self.follow; InnerBlock.follow | Statement.first   end
  end

  class ConstantDeclaration
    def self.first;  Set['const']  | EMPTY_SET end
    def self.follow; VariableDeclaration.first | FunctionDeclaration.first | Declaration.follow end
  end

  class ConstantList
    def self.first;  Constant.first end
    def self.follow; Set[';'] end
  end
  
  class Constant
    def self.first;  Set[IDENT] end
    def self.follow; Set[','] | ConstantList.follow end
  end

  class VariableDeclaration
    def self.first;  Set['var']     | EMPTY_SET end
    def self.follow; FunctionDeclaration.first | Declaration.follow end
  end
  
  class VariableList
    def self.first;  Var.first end
    def self.follow; Set[';']  end
  end
  
  class Var
    def self.first;  IdentifierList.first           end
    def self.follow; Set[','] | VariableList.follow end
  end

  class IdentifierList
    def self.first;  Set[IDENT]     end
    def self.follow; Set[',', ':']  end
  end

  class FunctionDeclaration
    def self.first;  FunctionList.first end
    def self.follow; Declaration.follow end
  end
  
  class FunctionList
    def self.first;  Function.first              end
    def self.follow; FunctionDeclaration.follow  end  
  end
  
  class Function 
    def self.first;  Set['function']     end
    def self.follow; FunctionList.follow end
  end

  class StatementList
    def self.first;  Statement.first end
    def self.follow; Set['end']      end
  end

  class Statement
    def self.first;  Set[IDENT, 'return', 'read', 'print', 'call', 'begin', 'if', 'while', 'for'] | EMPTY_SET end
    def self.follow; Block.follow | StatementList.follow | Set['else',',']                                    end
  end

  class Type
    def self.first;  BaseType.first | Array.first end
    def self.follow; Var.follow  end
  end

  class Expression
    def self.first;  SimpleExpression.first end
    def self.follow; Set[',','then','do'] | ExpressionList.follow | Statement.follow end
  end

  class SimpleExpression
    def self.first;  Term.first | Set['-']           end
    def self.follow; Relop.first | Expression.follow end
  end

  class Term
    def self.first;  Factor.first            end
    def self.follow; AddSubOp.first | Expression.follow end
  end

  class Factor
    def self.first;  Set[IDENT, INTEGER, TRUE, FALSE, STRING, '#', '(', 'call', '!'] end
    def self.follow; MultDivOp.first | Term.follow                               end
  end

  class AddSubOp
    def self.first;  Set['+', '-', '||'] end
    def self.follow; Term.first          end
  end

  class MultDivOp
    def self.first;  Set['*', "/", 'MOD', '&&'] end
    def self.follow; Factor.first               end
  end

  class Relop
    def self.first;  Set['==', '!=', '<', '>', '<=', '>='] end
    def self.follow; Expression.first                      end
  end
  
  class ExpressionList
    def self.first;  Expression.first            end
    def self.follow; Statement.follow | Set[')'] end
  end
  
  class FormalParameterList
    def self.first;  Set['('] | EMPTY_SET end
    def self.follow; Set['->']            end
  end
  
  class ActualParameterList
    def self.first;  Set['(']                         end
    def self.follow; Statement.follow | Factor.follow end
  end
  
  class Array
    def self.first;  Set['array'] end
    def self.follow; Type.follow  end
  end
  
  class Range
    def self.first;  Set[INTEGER] end
    def self.follow; Set['do']    end
  end
  
  class BaseType
    def self.first;  Set[INTEGER, BOOLEAN, STRING]  end
    def self.follow; ParamType.follow | Type.follow end
  end
  
  class ParamType
    def self.first;  BaseType.first | Array.first end
    def self.follow; ReturnType.follow            end
  end
  
  class ReturnType
    def self.first;  ParamType.first | Set[VOID] end
    def self.follow; Block.first                 end
  end
end