#coding:utf-8

module SimTab
  ##################################################################
  # 说明
  # 这个模块用于符合人类直觉的二维表处理,方便处理报表
  # 一般格式是 [[表头], [记录], ...]
  # 所有的操作处理都是针对记录不针对表头的
  # 表头的格式由人主观决定,只提供绑定方法
  ##################################################################

  ##################################################################
  # 读取报表
  ##################################################################
  
  def self.读取报表 路径,分隔符="\t"
    begin
      File.read(路径).gsub("\r","").split("\n").map{|l|l.split(分隔符)}
    rescue
      File.read(路径).force_encoding('GBK').encode("UTF-8").gsub("\r","").split("\n").map{|l|l.split(分隔符)}
    end
  end

  def self.读取csv 路径,format=:raw
    require 'csv'
    csv = File.read(路径).force_encoding("GBK").encode("UTF-8")
    content = CSV.parse(csv, headers:(format==:csv))
    table = content.绑定表头 content[0]
    return table
  end

  def self.读取html 文档
    doc = Nokogiri::HTML(文档)
    table = []
    doc.css("table").css("tr").each do|tr|
      record = []
      tr.css("td").each do|td|
        record << td.text
      end
      table << record
    end
    return table
  end

  ##################################################################
  # 表头
  # 如果已有表头,只需要'#绑定表头'指定表头即可
  # 如果没有表头,可以'#表头'自动生成表头,也可以指定'#生成表头'再'#绑定表头'
  ##################################################################

  def 生成表头 前缀=''
    max = self.inject(0){|max,item|(max < item.size ? item.size : max)}
    @表头 = Array.new(max){|i|i.to_s}
    self.unshift @表头
    @表头
  end

  def 绑定表头 表头
    @表头 = 表头 if 表头.instance_of?(Array)
    self.each do|记录|
      记录.绑定表头 表头 if 记录.instance_of?(Array)
    end
  end

  def 表头
    @表头 ||= []
    if !@表头 or @表头.empty?
      自定义表头 = 生成表头
      绑定表头 自定义表头
    end
    @表头
  end
  
  def 去掉表头
    @表头 = []
    self.shift # 只去掉形式上的表头,不会去掉记录的内联表头,以便恢复; 如想彻底去掉每条记录的表头,可绑定一个空表头
    self
  end

  def 展示表头
    索引表 = []
    @表头.each_with_index{|c,i|索引表 << "#{"%02s"%i}: #{c}"}
    索引表.join("\n")
  end

  # 特殊的双层表头，计算时转化为单层（原单层不变）
  def self.解析双层表头 列表
    return 列表 unless 列表[0].instance_of?(Array)
    表头 = []
    列表[0].each_with_index do|item,index|
      item=='' and index==0 and head = ''
      item=='' and index >0 and head = 表头[-1].split("#")[0]
      item!='' and head = item
      表头 << [head, 列表[1][index]].join("#")
    end if 列表.size == 2 && 列表[0].instance_of?(Array)
    if 列表[0].size < 列表[1].size
      num = 列表[1].size - 列表[0].size
      head = 表头[-1].split("#")[0]
      表头 += 列表[1][-1*num..-1].map{|i|"#{head}##{i}"}
    end
    return 表头
  end

  # 特殊的双层表头，输出前转化为多层（原单层不变）
  def self.生成双层表头 列表
    表头 = 列表.map{|复合表头|复合表头.split("#")}
    return [列表] if 表头[0].size==1
    row1,row2 = [],[]
    表头.each do|items|
      row1 << items[0]
      row2 << items[1]
    end
    return [row1,row2]
  end

  ##################################################################
  # 查询（行）、选择（列）、排序
  # 这里的计算结果都是生成新表
  ##################################################################
  
  def 字段查询 字段,内容
    索引 = self.表头.index(字段)
    新表 = [self.表头]+self.select{|c|c[索引]==内容}
    新表.绑定表头 self.表头
    新表
  end
  
  def 查询
    结果 = []
    self[1..-1].each do|记录|
      yield(记录) and (结果.push 记录)
    end
    新表 = [self.表头]+结果
    新表.绑定表头 self.表头
    新表
  end

  def 自定义排序
    字典,逆序,counter = {},nil,0
    self[1..-1].each_with_index do|记录,索引|
      键,逆序 = yield(记录)
      字典[键+"_#{"%010d"%counter}"] = 索引+1
      counter += 1
    end
    结果 = 字典.keys.sort.inject([]) do|结果,键|
      结果 << self[字典[键]]
      结果
    end
    逆序==:reverse and 结果.reverse!
    新表 = [self[0]]+结果
    新表.绑定表头 self.表头
    新表
  end
  
  def 排序
    新表 = [self[0]]+self[1..-1].sort
    新表.绑定表头 self.表头
    新表
  end
  
  def 逆序
    新表 = [self[0]]+self[1..-1].reverse
    新表.绑定表头 self.表头
    新表
  end

  # 可以使用“.字段(index|"column"|...)”查询，找不到查询名称的场合用名称做占位符
  def 字段 *属性表
    字段表,新表头 = [],[]
    属性表.each do|属性|
      if 索引 = self.表头.index(属性)
        字段表 << self[索引]
        新表头 << 属性
      else
        字段表 << 属性
        新表头 << 属性.to_s
      end
    end
    if 字段表.size>1
      字段表.绑定表头 新表头
      字段表
    else
      字段表[0]
    end
  end

  # select 在集合中指选择符合条件的某些元素，在SQL中指投影到具体的列上，这里偏向后者，前者可以对应查询
  def 选择 *字段列表 # col_num or 'col_name' or filler
    字段索引 = 字段列表.map{|f|r = f.instance_of?(Integer) ?  f : self.表头.index(f); r ? r : f }
    新表头 = 字段列表.map{|f|r = f.instance_of?(Integer) ?  self.表头[f] : f; r ? f : r }
    新表 = [新表头]+self[1..-1].map{|记录|字段索引.map{|索引|索引.instance_of?(Integer) ? 记录[索引] : 索引}}
    新表.绑定表头 新表头
    新表
  end

  def 拼接 另一个表
    新表头 = self.表头 + 另一个表.表头
    新表 = [新表头]+self[1..-1].product(另一个表[1..-1]).map{|t1,t2|t1+t2}
    新表.绑定表头(新表头)
    return 新表
  end

  ##################################################################
  # 统计
  ##################################################################

  def 统计 字段
    结果 = {}
    索引 = self[0].index(字段)
    self[1..-1].each do|记录|
      结果[ 记录[索引] ] ||= []
      结果[ 记录[索引] ] << 记录
    end if 索引
    结果
  end

  def 字段条目数统计 路径='.'
    字段唯一统计 = []
    Dir.mkdir(路径) unless File.exist?(路径)
    self[0].each do|字段|
      统计表 = self.统计 字段
      字段数值统计 = []
      统计表.each do|字段值,条目|
        字段数值统计 << "#{字段值}\t:\t#{条目.size}"
      end
      字段唯一统计 << "#{字段}\t:\t#{统计表.keys.size}"
      Dir.mkdir("#{路径}/字段数值统计") unless File.exist?("#{路径}/字段数值统计")
      File.write "#{路径}/字段数值统计/#{字段}(#{统计表.keys.size}).txt", 字段数值统计.join("\n")
    end
    File.write "#{路径}/字段唯一统计.txt", 字段唯一统计.join("\n")
  end

  def 建立档案
    文档 = []
    self[1..-1].each_with_index do|记录,记录索引|
      record = {'row' => 记录索引+1 }
      记录.each_with_index do|字段,字段索引|
        record[ self.表头[字段索引] ] = 字段
      end
      文档 << record
    end
    return 文档
  end

  ##################################################################
  # 排版
  ##################################################################

  def 展示列表
    self.map{|记录|记录.join("\t")}.join("\n")
  end

end

class Array
  attr_reader :表头
  include SimTab
end
