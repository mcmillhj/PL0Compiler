#
# NameError.rb
#
# Forwards errors and warnings from the NameStack 
# program to the compiler error log
######################################################################
require_relative '../PL0CompilerError.rb'

class NamingError < PL0CompilerError
  def self.warn(warn_string)
    name_warn_string = "Name: " + warn_string
    self.superclass.warn(name_warn_string)
  end
  
  def self.log(error_string)
    self.superclass.log("Name", error_string)
  end
end