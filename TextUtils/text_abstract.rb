#coding:utf-8

module TextAbstract

  # 移植以前的facility/helpers/String::draw_fragments
  # 特定环境下的遗留方法，不推荐常用
  def self.draw_fragments text,pre_flag,post_flag
    context,fragments = [],[]
    temp,flag = "",false
    text.each_line do|line|
      if pre_flag.match(line)
        temp = String.new if flag == false
        flag = true 
      end
      if flag == true
        temp << line # base on line!
      else
        context << line
      end
      if post_flag.match(line)
        flag = false
        fragments << temp
        temp = String.new
      end
    end
    context << temp if flag == true # exist pre_flag but no post_flag
    fragments.delete("")
    return context.join(),fragments
  end

  # 用来重写以前的facility/helpers/String::match_fragments
  # start和finish有严格的先后顺序，一段不完不起另一段
  def self.match_paragraph text,start,finish
    paragraphs,current_text = [],text.clone
    until current_text==""
      return paragraphs unless current_text.include?(start) # 严格匹配开始
      start_split = current_text.split(start)
      current_text = start_split[1..-1].join(start)
      return paragraphs unless current_text.include?(finish) # 严格匹配结束
      finish_split = current_text.split(finish)
      context = finish_split[0]
      current_text = finish_split[1..-1].join(finish)+(text[-1*finish.size..-1]==finish ? finish : "")
      paragraphs << context
    end
    return paragraphs
  end
  
  # start和finish是可以嵌套的，即一个start和finish包含在另一个start和finish内，但在全局上还是顺序的
  def self.match_cascade text,start,finish 
    paragraphs,current_text = [],text
    return paragraphs unless text.include?(start) or text.include?(finish)
    current_pos,parent_pos = paragraphs,[paragraphs]
    until current_text==""
      st_pos = (current_text.include?(start) ? current_text.split(start)[0] : current_text).size
      fn_pos = (current_text.include?(finish) ? current_text.split(finish)[0] : current_text).size
      if fn_pos==st_pos # 无标志或标志互包含
        current_pos << current_text
        current_text = ""
      end
      if fn_pos < st_pos # 结束在前
        csp = current_text.split(finish)
        current_pos << csp[0]
        current_pos << finish # 本级完成
        cur_parent = parent_pos.pop # 取回上一级
        current_pos = cur_parent # 返回上一级
        current_text = current_text.sub(csp[0],"").sub(finish,"")
      end
      if st_pos < fn_pos # 开始在前
        csp = current_text.split(start)
        current_pos << csp[0] unless csp[0]=="" # 本级内容加入
        current_pos << [start] # 下一级内容加入
        parent_pos << current_pos # 本级加入上下文
        current_pos = current_pos[-1]
        current_text = current_text.sub(csp[0],"").sub(start,"")
      end
    end
    return paragraphs
  end
  
  def self.match_html_tag html,tag
    paragraphs = self.match_cascade(html,"<#{tag}","</#{tag}>")
  end
  
end