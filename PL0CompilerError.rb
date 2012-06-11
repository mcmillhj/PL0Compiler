#
# PL0CompilerError.rb
#
# Catalogs all error messages during compilation then 
# prints them to STDOUT after compilation has terminated
##########################################################

class PL0CompilerError < StandardError
   @@parser_error_log = []
   @@lexer_error_log  = []
   @@name_error_log   = []
   @@semantic_error_log = []
   @@err_cnt          = 0
   
   # Sends a warning message to STDOUT 
   def self.warn(warn_string)
     $stderr.puts "#{warn_string}\n"
   end
   
   # logs errors in their respective lists
   def self.log(from, log_string)
     @@err_cnt += 1
     if from == "Parser"
       @@parser_error_log.push log_string
     elsif from == "Tokenizer"
       @@lexer_error_log.push log_string
     elsif from == "Name"
       @@name_error_log.push log_string
     elsif from == "Semantic Analyzer"
       @@semantic_error_log.push log_string
     end
   end
   
   # Dumps all errors to the STDOUT stream
   def self.dump()
     if not @@lexer_error_log.empty? or not @@parser_error_log.empty? or not @@name_error_log.empty? or not @@semantic_error_log.empty?
       puts "Encountered #{@@err_cnt} errors during compilation\n" 
     else
       puts "Parse successful"
     end
     
     $stdout.flush
     sleep 0.5
     
     if not @@lexer_error_log.empty?
       puts "\nTokenizer Errors:"
       $stdout.flush
       sleep 0.5
       @@lexer_error_log.each {|e| $stderr.puts "\t#{e}\n" }
       sleep 0.5
     end 
     
     if not @@parser_error_log.empty?
       puts "Parser Errors:"
       $stdout.flush
       sleep 0.5
       @@parser_error_log.each {|e| $stderr.puts "\t#{e}\n" }
       sleep 0.5
     end 
     
     if not @@name_error_log.empty?
       puts "Name Errors:"
       $stdout.flush
       sleep 0.5
       @@name_error_log.each {|e| $stderr.puts "\t#{e}\n" }
       sleep 0.5
     end 
     
     if not @@semantic_error_log.empty?
       puts "Semantic Errors:"
       $stdout.flush
       sleep 0.5
       @@semantic_error_log.each {|e| $stderr.puts "\t#{e}\n" }
       sleep 0.5
     end 
   end
end