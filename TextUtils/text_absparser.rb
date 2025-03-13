#coding:utf-8
# require 'custom-core/string'

module ABString
  # {:;} = Left Colon and Semicolon to Right Brace(LCSRB)
  # {name : params ; body}
  def parse_lcsrb string
    head = "{"
    tail = "}"
    sequences = TextAbstract.match_cascade(string.gsub("\r",""),head,tail)
    blocks = sequences.select{|i|i.instance_of?(Array)}
    
    blocks.inject({}) do|table,block|
      prename,prebody = block[1..-2].join.split(":")
      name = diet(prename)
      if prebody.include?(';')
        preparams,postbody = prebody.split(";")
        params = preparams.to_s.split(",").map{|r|diet(r)}
      else
        params,postbody = [],prebody
      end
      body = diet(postbody).split("\n").map{|line|diet(line)}.join("\n")
      table[name] = [name,params,body]
      table
    end
  end

  def parse string,option
    case option
    when :lcsrb
      parse_lcsrb(string)
    else
      string
    end
  end

  def diet string
    string.strip.gsub("\t"," ")
  end

  module_function :parse,:diet,:parse_lcsrb
end