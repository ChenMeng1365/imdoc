# imdoc

## Functions

### Tabot

读写excel文档的接口，支持MSOffice、Openoffice、Libre

ruby和python两种语言实现，由于它们都有基础的实现，所以只做补充

### TextUtils

包含处理各种文字加工需求的工具

`text_abstract`目标是复杂文本中特征字段的摘取和采集，它以加工处理文本、文本列表、文本树成为格式化数据作为主要目标
`text_mind`将其分解为一些列数据处理基本流程，再进行组合调用

```ruby
p "aaabbb".head? "aa"
p "cccddd".tail? "dd"
p "abcdef" - "c"
p "abcdef" / "c"
p "abedef".exchange "e", 'z' 

p ['a','b','c'].match(){|c|c>='b'}
p [1,2,3,4].reduce{|a,b|"#{a},#{b}"}

p ({a: 1, b: 2} + [1,3,5])

p "1111\na\n2222\nb\n3333\na\n4444\nb\n5555".draw_lines(/a/,/b/)
p "1111a2222b3333a4444b5555".match_cascade('a','b')
p "a11111a2222b3333a4444b5555b".match_paragraph('a','b')
p "a11111a2222b3333a4444b5555b".match_cascade('a','b')
p "a11111a2222b3333b4444a5555b".match_cascade('a','b')
p "<a>11111<a><a>2222</a><a>3333</a>4444</a>5555</a>".match_xml('a')
```

`text_absparser`是利用`text_abstract`的文本处理机制，制作的简易格式化文本块解析程序

```ruby
scripts = ABString.parse string, option
```

目前实现的文本格式为`option=:lcsrb`，即如下格式：

```text
...
{
  name : parameters ;
  body
}
...
```

它会被识别为一个大型脚本散列表中的一个键及对应的三元组：

```text
{
  ...
  name : [ name, parameters, body ]
  ...
}
```

它的名称Left Colon and Semicolon to Right Brace(LCSRB)也即是`{`、`}`、`:`、`;`这四个特殊字符的缩写，也就是保留字，不可用作其他用途或混写

`password`可以看作是一个随机密码生成工具，期待加入更加复杂的特征检测与满足

```ruby
p level_1 = Password.generate(length: 8, alphabet: 'abcdef'.split(''), use: [:alphabet,:number])
p level_2 = \
  Password.generate(length: 8, alphabet: 'abcdef'.split(''), use: [:alphabet,:number])+
  Password.generate(length: 4, specific: '!@#$%^&*()'.split(''), use: [:specific])+
  Password.generate(length: 8, alphabet: 'abcdef'.split(''), use: [:alphabet,:number])
```

### TinText

这是一个模板替换手段，通过扩展ERB实现

使用(( var ))绑定变量，使用Replacement内置的属性表取值

```ruby
string = "say (( pil ))"
Replacement.init
Replacement["pil"] = "die lord"
p TinText.instance(string),TinText.template(string)
Replacement.merge "pil"=>"die witch"
p TinText.instance(string),TinText.template(string)
```

和ERB一样，它支持结构化编排，使用\[\[ stat \]\]、{{ exp }}做闭包表达式计算，使用<< stat >>做结果输出

```ruby
Replacement.reset
Replacement['word']='bil'

a = %{ [[ (1..5).each do|i| \n dd {{j=i+1}}<< j >> ]]\n[[ if rand(2)==0 \n ((word)) ]]\n << Tum.iterate " a @var",3..7 >>}
b = TinText.unfolder(a)
c = TinText.template(a)
d = TinText.instance(a)
puts "书写：\n#{a}\n\n","展开：\n#{b}\n\n","模板：\n#{c}\n\n","估值：\n#{d}\n\n"
```

你可以做如下认知：

* (( var ))把变量绑定到内置缓存Replacement的同名属性上
* {{ exp }}把内置的ruby表达式估值，结果缓存在上下文中（不会直接作用于模板）
* << stat >>把内置的ruby表达式估值，结果直接反馈到模板实例中
* \[\[ stat \]\]做内置的模板控制，它可以多行（使用\n换行），可以是复杂的控制结构，注意它是元模板，不是ruby语句，还需要展开、模板化、实例化

Tum是一个扩展模块，用于定制<< 流控 >>的功能，欢迎继续扩展

### XMLUtils

XML模型的使用转化，一般将XML文档解析为[ 元素名, 属性散列表, 子元素列表 ]三部分，嵌套表示

现在使用`XMLUtils/XmlUtils`取代原有各模块, 新增了双向图功能

XmlNode

```ruby
@data = XmlParser.load "Repository/processdefinition"
a = XmlNode.copy @data

# 查询：
i = @data.search_elements{|item|item.name=="task-node"}
i.each {|e|p e.attributes["name"]}

# 删除：
outs = @data.delete_elements{|item|["分拣","管理员出库签字","出库搬运"].include?(item.attributes["name"])}
outs.each{|e|p e.attributes["name"]}
p @data.search_elements{|e|e.name=="task-node"}.size
p a.search_elements{|e|e.name=="task-node"}.size

# 输出：
File.open('Warehouse/out_parser.xml','w'){|f|f.puts @data.to_xml}
File.open('Warehouse/out_parser.json','w'){|f|f.puts @data.to_json}
File.open('Warehouse/out_parser.yaml','w'){|f|f.puts @data.to_yaml}
```

XmlModel

```ruby
xc = XmlModel.new "jpdl"
xc.load "Repository/processdefinition"

# 转化为文档：
root = xc.find(){|item|item.attributes['xmlns']=="urn:jbpm.org:jpdl-3.2"}
root = xc.find(){|item|item.name =='fork'}
xc.to_xml "Warehouse/out_doc",root
xc.to_json "Warehouse/out_doc",root
xc.to_yaml "Warehouse/out_doc",root
p YAML.load(root.to_yaml)

# 部分元素转换：
@data = XmlParser.load "Repository/processdefinition"
xc.convert_part @data,"task-node"
xc.context.each do|k,v|
  puts "#####{k}:####"
  v.each{|i|p i.attributes["name"]}
end

# 基本查询方法：
xc["transition"].each do|task_node| p task_node.attributes['name']end
# 一般查询方法：（查找属性）
items = xc.find_all{|item|item.attributes["name"]=='申请送货'}
items.each do|i| p i.attributes["name"] end
items = xc.find_all("transition"){|item|item.attributes["to"]=="入库搬运任务分配"}
p items[0].attributes["name"]
items = xc["transition"].find_all{|item|item.attributes["to"]=="入库搬运任务分配"}
p items[0].attributes["name"]
item = xc.find{|item|item.attributes["to"]=="join1"}
p item.attributes["name"] # 注：同样的元素中有些有名字有些则没有，所以有些时候为nil
# 比较野的查询方法：（查找子元素）
items = xc.find_all{|item|item.elements.find{|subitem|subitem.attributes["to"]=="入库搬运"}}
items.each do|item| p item.attributes["name"]end

# 删除方法：
items = xc.del_items("task-node") # 不带条件块或条件块为{}
puts "****删除元素****"
items.each do|item|p item.attributes["name"]end
puts "****剩余元素****"
xc["task-node"].each do|item|p item.attributes["name"]end
puts "=======删除后======="
items = xc.del_items("task-node"){|item|item.elements.find{|subitem|subitem.attributes["to"]=="入库搬运"}}
puts "****删除元素****"
items.each do|item|p item.attributes["name"]end
puts "****剩余元素****"
xc["task-node"].each do|item|p item.attributes["name"]end
```

### XYZ

格式化表格数据，我们已经找到了更好的替代项目neatjson，所以不再重复造轮子了

```shell
gem install neatjson # or gem 'neatjson'
```

`XYZ::Frame`

你可以直接使用neatjson的`JSON.pretty_generate(obj)`，也可以使用包装过的`XYZ::Frame.formation(obj)`或`obj.xyz_formation`

XYZ::Vector|List|Sequence

XYZ::Matrix|Table|HTablea

### EnData

EnData（__END__DATA）是一个脚本内数据整理方法，它通过声明一个文件头来直接附加数据，以便于调用和操作

目前支持三种格式：

* ruby脚本
* yaml
* json

原则上任何可打印的数据都可以添加，处理方法可自定义

文件头的格式为：

```ruby
__END__
[user@endata path]$ handler name1 args...
...
[user@endata path]$ handler name2 args...
...
```

当然也可以自定义，不过处理方法要适配

### CasetDown

CasetDown是一个markdown文档工具, 用于将markdown文档中的形式化代码提取出来重新编排和执行

默认使用`GEM:kramdown`作为解析器, 也可以替换为`GEM:rdiscount`

```ruby
require 'XMLUtils/XmlUtils'
script, tree = CasetDown.load("feature.md")
pp script.stack, tree.nodes
```

### PainPainter

PainPainter是一组制作矢量图的文档工具，画起来有点累

```shell
table1 = [
  ["node1", "port11", "vlan11", "desc11"],
  ["node1", "port12", "vlan12", "desc12"],
  ["node1", "port13", "vlan13", "desc13"]
]

table2 = [
  ["node2", "port21", "vlan21", "desc21"],
  ["node2", "port22", "vlan22", "desc22"],
  ["node2", "port23", "vlan23", "desc23"]
]

tables = [table1, table2]

File.write "sample.dot", DotPainter.make_portmap(tables)
```

## BUILDS

仓库之间的依赖较多, 采取松散的方式集成

```shell
gem build CasetDown/casetdown.gemspec

irb
> ['XMLUtils/XmlUtils', 'TextUtils/text_abstract', 'Tabot/simtab', 'CasetDown/casetdown'].each{|lib|require lib}
```

