#coding:utf-8
require 'csv'

module CasetDown
  module_function

  # handle table
  def loadcsv path,format=:raw
    begin
      csv = File.read(path).force_encoding("GBK").encode("UTF-8")
    rescue
      csv = File.read(path).encode("UTF-8")
    end
    content = CSV.parse(csv, headers:(format==:csv))
    table = content.绑定表头 content[0]
    return table
  end
  
  def maketab table
    printab = table.map{|row|"|"+row.join("|")+"|"}
    printab.insert 1, Array.new(table[0].size, '|---').join+"|"
    return printab.join("\n")
  end

  def render_table cds, option={ stream: nil, opt: []} # empty, :wtab, :rtab, :rendfile
    $_tmp_endata_ = {}
    # write table to csv file
    docs = CasetDown::Check.all(cds)
    docs.each_with_index do|doc,index|
      if doc[:name]=='table'
        table_name = ( index-1 >= 0 && docs[index-1][:name]=='p' && docs[index-1][:text].strip[0..1]=='(('  && docs[index-1][:text].strip[-2..-1]=='))' ) ? docs[index-1][:text][2..-3].strip : 'Anonymous'
        table_body = [doc[:head]]+doc[:body]
        $_tmp_endata_["[table@endata ~]$ruby #{table_name}"] = table_body.to_s
        CSV.open(table_name+".csv","w")do|writer|
          table_body.each do|record|
            writer << record
          end
        end if option[:opt].include?(:wtab)
      end
    end

    # load table from csv file
    result = {}
    codtab = docs.select{|doc|doc[:name]=='code'}
    codtab.each do|code|
      interpreter, namespace, config, target, flow, segment, input, output, rows, cols = magic_head code
      next unless output.to_s[-4..-1]=='.csv'
      tab = loadcsv(output)
      seltab = rows.inject([tab[0]]) do|seltab,row|
        seltab += [tab[row]] if row.is_a?(Integer)
        seltab += tab[row]   if row.is_a?(Range)
        seltab
      end
      seltab.绑定表头 seltab[0]
      newtab = seltab.选择(*cols)
      result[output] = maketab(newtab)
      $_tmp_endata_["[table@endata ~]$ruby #{output}"] = newtab.to_s
    end

    $_tmp_endata_.each do|head, table|
      ($_scr_tail_ ||= "__END__") << "\n#{head}\n#{table}\n"
      ($_erl_tail_ ||= "") << "\n\n"+ToErlang.fact(head.split('$ruby ')[1], ToErlang.table(eval(table)))
    end
    origin_text = option[:stream] || cds[:doc].text
    result.each do|output, newtab|
      wrapped = "((#{output}))\n\n#{newtab}"
      origins = CasetDown.search_output(origin_text, output)
      origins.each do|origin|
        origin_text = origin_text.gsub(origin, wrapped)
      end
    end if option[:opt].include?(:rtab)

    if option[:opt].include?(:rendfile)
      pazz = cds[:path].split('.')
      pazz.insert(-2,Time.new.strftime("%Y%m%d%H%M%S"))
      File.write pazz.join('.'), origin_text
    end
    return { text: origin_text, data: $_scr_tail_, fact: ($_erl_tail_||nil)}
  end
end