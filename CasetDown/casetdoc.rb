#coding:utf-8

module CasetDown
  module Check
    module_function

    def all cds
      epool = cds[:src].stack.inject([]) do|epool, cd|
        res = nil
        [:head, :table, :para, :pre, :list, :quote].each do|tag|
          res ||= CasetDown::Check.send tag, cd
        end
        epool += res.instance_of?(Array) ? res : [res]
      end.compact
    end

    def head cd
      if %w{h1 h2 h3 h4 h5 h6}.include? cd.name
        unless cd.elements.empty?
          ha = {name: cd.name, text: cd.attributes[:text], inline: [] }
          cd.elements.each{|sub|ha[:inline]<<(sub.name=='a' ? a(sub) : {})}
          ha
        else
          {name: cd.name, text: cd.attributes[:text] }
        end
      else
        nil
      end
    end

    def table cd
      if cd.name=='table'
        hd = cd.to_doc['table'][1]['thead'][1]['tr'][1..-1].map{|th|th['th'][0][:text]}
        bd = cd.to_doc['table'][2]['tbody'][1..-1].map{|tr|tr['tr'][1..-1].map{|td|td['td'][0][:text]}}
        {name: 'table', head: hd, body: bd}
      else
        nil
      end
    end

    def para cd
      if cd.name=='p'
        cur = []
        cur << (cd.attributes[:text] ? {name: 'p', text: cd.attributes[:text]||cd.attributes["text"]} : nil)
        cd.elements.each do|cs|
          cur << code(cs)
          cur << img(cs)
          cur << a(cs)
        end
        return cur
      else
        nil
      end
    end

    def img cd
      if cd.name=='img'
        {name: 'img', src: cd.attributes['src'], alt: cd.attributes['alt']}
      else
        nil
      end
    end

    def a cd
      if cd.name=='a'
        {name: 'a', href: cd.attributes['href'], text: cd.attributes[:text]}
      else
        nil
      end
    end

    def pre cd
      if cd.name=='pre'
        code(cd.elements.first)
      else
        nil
      end
    end

    def code cd
      if cd.name=='code'
        {name: 'code', class: (cd.attributes['class'] ? cd.attributes['class'] : :default), code: cd.attributes[:text]}
      else
        nil
      end
    end

    def list cd
      # TODO: ONLY TOP LEVEL, PENDING TO RECURSION
      if cd.name=='ul'
        subs = cd.elements.inject([]) do|subs, li|
          sub = {name: 'li', text: li.attributes[:text]}
          li.elements.each do|subsub|
            sub.merge!(inline: quote(subsub)) if subsub.name=='blockquote'
            sub.merge!(inline: code(subsub)) if subsub.name=='code'
            sub.merge!(inline: img(subsub)) if subsub.name=='img'
            sub.merge!(inline: a(subsub)) if subsub.name=='a'
          end
          subs << sub
        end
        {name: 'ul', list: subs}
      else
        nil
      end
    end

    def quote cd
      # TODO: ONLY TOP LEVEL, PENDING TO RECURSION
      if cd.name=='blockquote'
        {name: 'blockquote', quote: cd.to_doc['blockquote'][1]['p'][0][:text]}
      else
        nil
      end
    end

  end
end