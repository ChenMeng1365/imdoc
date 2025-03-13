#coding:utf-8

module TextAbstract

  module Type
    def int radix=10
      self.to_i(radix)
    end

    def float tail=2
      self.to_f.round(tail)
    end

    def precent tail=2
      (self.to_f*100).round(tail).to_s+"%"
    end

    def text format=:raw
      return self         if format==:raw
      return self.to_json if format==:meta
    end

    def bool
      return true   if self.downcase=='true'
      return false  if self.downcase=='false'
      return self.empty?
    end
  end

  module TextOperator
    def head? prefix, strip=false #=> bool
      left = strip ? self.strip : self
      left[0..(prefix.length-1)]==prefix
    end

    def tail? postfix, strip=false #=> bool
      left = strip ? self.strip : self
      left[(-1*postfix.length)..-1]==postfix
    end

    # def include? text #=> bool

    # def empty? #=> bool

    def matches pattern, mode=:one #=> match
      return self.match(Regexp.new pattern) if mode==:one
      return self.scan(Regexp.new pattern)  if mode==:all
      return self.scan(Regexp.union *pattern.map{|pat|Regexp.new(pat)})  if mode==:union
    end

    def draw_lines preflag, postflag #=> text, list
      restext, contexts = TextAbstract.draw_fragments self, preflag, postflag
    end

    def match_paragraph start, finish #=> list
      paragraphs = TextAbstract.match_paragraph self, start, finish
    end

    def match_cascade start, finish #=> list
      paragraphs = TextAbstract.match_cascade self, start, finish
    end

    def match_xml tag #=> tree
      document = TextAbstract.match_html_tag self,tag
    end

    # def length #=> int
    # def size #=> int

    # def strip #=> text
    # def lstrip #=> text
    # def rstrip #=> text

    def join *texts #=> text
      self+texts.map{|t|t}.join
    end

    def cut index1, index2=0 #=> text
      self[(index1-1)..(index2-1)]
    end

    # def + text #=> concat text

    # def * text #=> repeat text

    def - text #=> text
      self.include?(text) ? self.split(text).first : self
    end

    def / text #=> list
      self.split(text)
    end

    def exchange text, newtext, num=:all #=> text
      num = 65535 if num==:all
      count = 0
      self.gsub(Regexp.new(text)) do |match|
        count += 1
        count <= num ? newtext : text
      end
    end
  end

  module ListOperator
    # def pop           #=> item
    # def push text     #=> list
    # def shift         #=> item
    # def unshift text  #=> list
    
    # def + list        #=> list
    # def - list        #=> list

    def catch *list #=> list(list)
      list.unshift(self)
    end
  
    # def find &block   #=> item
    # def select &block #=> list
    # def filter &block #=> list
    def match num=1, &block #=> bool | item | list
      return self.find(&block).nil?           if num ==0
      return self.find(&block)                if num ==1
      return self.select(&block)              if num ==:all
      return self.select(&block)[0..(num-1)]  if num > 1
    end

    def sub index1, index2=0 #=> list
      self[(index1-1)..(index2-1)]
    end

    # def map &block      #=> list
    # def collect &block  #=> list

    # def reduce(c) &block #=> item
    # def inject(c) &block #=> item
    # def join text #=> concat item ※ join(c) == reduce{|a,b|a+c+b}
  end

  module TreeOperator
    # def keys    #=> list
    # def values  #=> list

    # def [] key #=> item
    def get key #=> item
      self[key]
    end

    # def []= key, value #=> item
    def set key, value #=> item
      self[key] = value
    end

    def + oprand #=> tree
      index = self.keys.filter{|k|k.instance_of?(Integer)}.max
      index = index ? index+1 : 0
      if oprand.instance_of?(Hash)
        self.merge(oprand)
      elsif oprand.instance_of?(Array)
        self.merge oprand.reduce({}){|tr,op|index+=1;tr.merge({(index-1)=>op})}
      else
        self.merge({index=>oprand})
      end
    end
  end

end

class String
  include TextAbstract::Type
  include TextAbstract::TextOperator
end

class Array
  include TextAbstract::ListOperator
end

class Hash
  include TextAbstract::TreeOperator
end

