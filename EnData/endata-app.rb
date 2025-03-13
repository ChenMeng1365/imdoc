#coding:utf-8

##################################################################################################################
#
# EnData
#
# CASE: table from DATA
# USE:  EnData.table(table_name)
# 
# CASE: table1 × table2
# USE:  EnDataApp.join_table(table_name1, table_name2)
#
# CASE: table[head|body] >--(cut-head)--> table[body]
# USE: EnDataApp.get_body(table_name)
#
# CASE: table[head=[field*], record=[value*]] >----> tree{field=>value, ...}
# USE:  EnDataApp.make_doc(table)
#
# CASE: ${refname} >--(replace)--> reftext
# USE:  EnDataApp.make_ref(table, refname, reftext)
#
##################################################################################################################

module EnData
  module_function

  # [CUSTOM_YOUR_NAME@endata CUSTOM_YOUR_PATH]$ruby table
  def table name='table'
    EnData.load()
    EnData.parse()
    EnData.run(EnData.source EnData.select name: name)
  end

  def join_table name1, name2
    table1 = EnData.table(name1)
    table2 = EnData.table(name2)
    table1.绑定表头 table1.first
    table2.绑定表头 table2.first
    return table1.拼接 table2
  end

  def get_body name
    EnData.table(name)[1..-1]
  end

  def make_doc table
    return table[1..-1].inject([]) do|doc, record|
      rec = {}
      record.each_with_index{|value, index|rec[table[0][index]] = value}
      doc.push rec; doc
    end
  end

  def make_ref table, refname, reftext
    return table.inject([]) do|newtab, record|
      newrec = []
      record.each{|field|newrec << (field=="${#{refname}}" ? reftext : field)}
      newtab.push newrec; newtab
    end
  end

end
