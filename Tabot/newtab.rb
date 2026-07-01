#coding:utf-8
require 'json'

module Newtab
  module_function

  def trans_table file, sheet, env='conda activate py311', temp='_temp.json'
    $env ||= env
    table = %Q|python -c "import pandas as pd;pd.read_excel('#{file}',sheet_name='#{sheet}').to_json('#{temp}',orient='records',force_ascii=False)"|
    system("#{$env} && #{table}")
    doc = JSON.parse File.read(temp)
    File.delete(temp)
    return doc
  end

  def save_table data, file, sheet, env='conda activate py311', temp='_temp.json'
    $env ||= env
    File.write(temp, JSON.generate(data))
    table = %Q|python -c "import pandas as pd;pd.read_json('#{temp}').to_excel('#{file}',sheet_name='#{sheet}',index=False,header=False)"|
    system("#{$env} && #{table}")
    File.delete(temp)
  end

  def sheets file, env='conda activate py311', temp='_temp.rb'
    $env ||= env
    table = %Q|python -c "import pandas as pd; bk=pd.ExcelFile('#{file}'); file = open('#{temp}', 'w', encoding='utf-8'); file.write(str(bk.sheet_names)); file.close()"|
    system("#{$env} && #{table}")
    doc = eval(File.read(temp))
    File.delete(temp)
    return doc
  end

  def env set='conda activate py311'
    $env = set
  end
end