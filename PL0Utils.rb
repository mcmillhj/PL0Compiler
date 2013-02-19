#
# PL0Utils.rb
#
# Defines static utility functions to be used in compilation
#
# Hunter McMillen
# 2/7/2012
############################################################
module PL0Utils
  # finds the displacement from k to the nearest prime number
  def self.find_displacement(k)
    n = 1
    k = k + (k * 0.1) #add 10%
    
    #search for the nearest prime number
    while not prime?(n+k) do 
      n += 2
    end

    return n
  end

  # test to determine if a number is prime
  def self.prime?(n)
    2.upto(Math.sqrt(n)) do |i|
      if n % i == 0
        return false
      end
    end

   return true
  end  
end