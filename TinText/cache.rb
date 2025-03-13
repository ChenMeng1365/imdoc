#coding:utf-8

# a light cache
module Replacement
  def self.init
    @dictionary = {}
  end
  
  def self.reset
    init
  end

  def self.[] index
    @dictionary[index]
  end
  
  def self.[]= index,replacement
    @dictionary[index]= replacement
  end
  
  def self.merge hash
    @dictionary.merge! hash
  end
end
