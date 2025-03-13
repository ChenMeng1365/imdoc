#coding:utf-8
require 'rdiscount'

module CasetDown
  module_function
  
  #################################################################################################
  # Loader                                                                                        #
  #################################################################################################
  def load path, option={}
    args = {path: path}.merge(option)
    text = (File.read path).gsub("\r","").split("\n").map{|line|line.rstrip}.join("\n")
    return self.parse(text, args)
  end

  #################################################################################################
  # InlineStructs                                                                                 #
  #################################################################################################
  def parse text, option={}
    args = {
      parser: RDiscount, # parser := {Kramdown::Document | RDiscount} ★ Kramdown::Document无法处理好多重空行问题
      doc: true,
      tree: true,
      src: true,
      path: 'tmp'
    }.merge(option)
    document = args[:parser].new(text)
    html = "<html>"+document.to_html+"</html>"
    script, tree = [],{}
    XmlParser.parse(html).elements.each do|node|
      doc = node.to_a
      script << node
      tree[doc[0]] ||= []
      tree[doc[0]] << node
    end
    result = {path: args[:path]}
    result[:src]  = Script.new(native: script) if args[:src]
    result[:tree] = Tree.new(native: tree)     if args[:tree]
    result[:doc]  = document                   if args[:doc]
    return result
  end
  
  class Tree
    def initialize options={}
      @content ||= options[:native]
      @content ||= JSON.parse(options[:json]) if options[:json]
      @content ||= CasetDown.load(options[:path])[-1] if options[:path]
      @content ||= CasetDown.parse(options[:doc])[-1] if options[:doc]
      @content ||= {}
    end
    
    def nodes &block
      block = lambda{|content|content} unless block
      block.call(@content)
    end
  end
  
  class Script
    def initialize options={}
      @content ||= options[:native]
      @content ||= JSON.parse(options[:json]) if options[:json]
      @content ||= CasetDown.load(options[:path])[0] if options[:path]
      @content ||= CasetDown.parse(options[:doc])[0] if options[:doc]
      @content ||= []
    end

    def stack &block
      block = lambda{|content|content} unless block
      block.call(@content)
    end
  end
end
