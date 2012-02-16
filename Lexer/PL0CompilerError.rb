class PL0CompilerError < StandardError
   def self.warn(warn_string)
     $stderr.puts(warn_string)
   end
end