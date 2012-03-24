class PL0CompilerError < StandardError
   @@error_log = [] #string that holds all of the errors encountered in the file
   
   def self.warn(warn_string)
     $stderr.puts "#{warn_string}\n"
   end
   
   def self.log(log_string)
     @@error_log.push log_string
   end
   
   def self.dump()
     if not @@error_log.empty?
       $stderr.puts "\nCompilation Errors:"
       @@error_log.each {|e| $stderr.puts "#{e}\n" }
     else
       $stdout.puts "\nParse successful"
     end 
   end
end