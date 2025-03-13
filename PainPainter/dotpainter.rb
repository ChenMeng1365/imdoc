#coding:utf-8

# cover graphviz.dot
module DotPainter
  module_function
  
  # 制作网络设备接口关系模板
  # [hostname, portname, services, anotherside]
  def make_portmap tables
    board,gnc = [], 0
    tables.each do|table|
      lnc,interinstance,endinstance,relationship = 0,[],[],[]
      gnc += 1
      head,body,tail = "subgraph cluster#{gnc} {",[], "}"
      body << %Q{  label="#{table.map{|i|i[0]}.uniq.first}"}
      table.each do|record|
        body << %Q{  node#{10000*gnc+lnc} [shape=box, label="#{record[1]}"]}
        interinstance << %Q{inter#{10000*gnc+lnc} [label="#{record[2]}"]}
        endinstance << %Q{subgraph cluster#{10000*gnc+lnc} {\n  label="#{record[3]}"\n  ender#{10000*gnc+lnc} [shape=box,label=""]\n}}
        relationship << %Q{node#{10000*gnc+lnc} -- inter#{10000*gnc+lnc} -- ender#{10000*gnc+lnc}}
        lnc += 1
      end
      board += [[head,body.join("\n"),tail].join("\n")]
      board += [interinstance.join("\n")]
      board += [endinstance.join("\n")]
      board += [relationship.join("\n")]
      
    end
    ["graph G {",board.map{|i|i.split("\n").map{|l|"  #{l}"}.join("\n")},"}"].join("\n\n")
  end
end