#coding:utf-8
require 'erb'

module TinText
  def self.translate word
    unless Replacement[word]==nil
      return Replacement[word]
    else
      return "((#{word}))"
    end
  end

  def self.unfolder raw
    # <<..>> => <%=..%>
    # {{..}} => <%..%>
    # [[..\n....]] => <%..%>..<%..%>
    raw.gsub(/\<\<\s*(.+?)\s*\>\>/,"<%=\\1%>")
       .gsub(/\{\{\s*(.+?)\s*\}\}/,"<%\\1%>")
       .gsub(/\{\{\s*(.+?)\s*/,"<%\\1").gsub(/\s*\}\}/,"\\1%>")
       .gsub(/\[\[\s*(.+?)\s*\n/,"<%\\1%>").gsub(/\]\]/,"<%end%>")
  end

  def self.template raw
    # ${..} ((...)) => <%=...%>
    raw.gsub(/\(\(\s*(.+?)\s*\)\)/,"<%=TinText::translate('\\1')%>").gsub(/\$\{\s*(.+?)\s*\}/,"<%=TinText::translate('\\1')%>")
  end
  
  def self.instance raw,tag=:pre
    if tag==:pre
      a = self.template raw
      b = ERB.new(a).result
      c = self.unfolder b
      ERB.new(c).result
    else # :post
      a = self.unfolder raw
      b = ERB.new(a).result
      c = self.template b
      ERB.new(c).result
    end
  end
  
  def self.tt raw;self.template raw;end
  def self.ti fla;self.instance fla;end
end
