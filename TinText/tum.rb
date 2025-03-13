#coding:utf-8

# Tum = Text Unfold Method
module Tum
  def self.repeat statement, times
    Array.new(times,statement).join("\n")
  end
  
  # statement = '... @var ...', var in range
  def self.iterate statement, range
    range.collect{|item| statement.gsub("@var",item.to_s) }.join("\n")
  end
end
