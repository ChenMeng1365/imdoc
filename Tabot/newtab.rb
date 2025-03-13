#coding:utf-8
require 'json'

module Newtab
  module_function

  def trans_table file, sheet, env='conda activate py311', temp='_temp.json'
    table = %Q|python -c "import pandas as pd;pd.read_excel('#{file}',sheet_name='#{sheet}').to_json('#{temp}',orient='records',force_ascii=False)"|
    system("#{env} && #{table}")
    doc = JSON.parse File.read(temp)
    File.delete(temp)
    return doc
  end
end