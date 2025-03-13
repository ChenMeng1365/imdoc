#coding:utf-8
# for openoffice && libre
require 'roo' # gem install roo
require 'roo-xls' # gem install roo-xls

class RooBot
  attr_accessor :table
  
  def initialize path=nil
    unless File.exist?(path)
      tpath = path+".xls" if File.exist?("#{path}.xls")
      tpath = path+".xlsx" if File.exist?("#{path}.xlsx")
    else
      tpath = path
    end
    @excel = Roo::Excel.new(tpath) if tpath[-4..-1]=='.xls'
    @excel = Roo::Excelx.new(tpath) if tpath[-5..-1]=='.xlsx'
    @excel.default_sheet = @excel.sheets.first
    #if path && File.exist?(path)
    #  if path.include?('.xls')
    #    @excel = Roo::Excel.new(path)
    #  elsif path.include?('.xlsx')
    #    @excel = Roo::Excelx.new(path)
    #  end
    #  @excel.default_sheet = @excel.sheets.first
    #elsif File.exist?("#{path}.xls")
    #  @excel = Roo::Excel.new("#{path}.xls")
    #  @excel.default_sheet = @excel.sheets.first
    #elsif File.exist?("#{path}.xlsx")
    #  @excel = Roo::Excelx.new("#{path}.xlsx")
    #  @excel.default_sheet = @excel.sheets.first
    #end
  end
  
  def sheets
    @excel.sheets
  end
  
  def sheet name
    if name.is_a?(Numeric)
      @excel.default_sheet = @excel.sheets[name]
    else
      index = @excel.sheets.index(name)
      @excel.default_sheet = @excel.sheets[index]
    end
  end

  LATIN = {
    1=>"A",2=>"B",3=>"C",4=>"D",5=>"E",6=>"F",7=>"G",
    8=>"H",9=>"I",10=>"J",11=>"K",12=>"L",13=>"M",14=>"N",
    15=>"O",16=>"P",17=>"Q",18=>"R",19=>"S",20=>"T",
    21=>"U",22=>"V",23=>"W",24=>"X",25=>"Y",26=>"Z"
  }
  def latin column # excel: maxium 234 columns!
    if column%26==0
      return LATIN[column/26-1].to_s+LATIN[26]
    else
      return LATIN[column/26].to_s+LATIN[column%26]
    end
  end

  def get_table
    @table = []
    first, last = @excel.first_row, @excel.last_row
    left, right = @excel.first_column, @excel.last_column
    (first..last).each do|num|
      record = []
      (left..right).each{|field|record<<@excel.cell(num,latin(field))}
      @table << record
    end
    @table
  end
  
  def table
    get_table unless @table
    @table
  end

  def create_table path,hash_table
    book = Spreadsheet::Workbook.new
    hash_table.each do|name,table|
      sheet = book.create_worksheet
      sheet.name = name
      table.each_with_index do|record,row_index|
        record.each_with_index do|data,col_index|
          sheet[row_index,col_index] = data
        end
      end
    end
    book.write path
  end
  
  # many problems for modifying, best way is create new
  def set_table path,template,hash_table
    tpath = template.include?('.xls') ? template : "#{template}.xls"
    book = Spreadsheet.open(tpath)
    hash_table.each do|name,table|
      sheet = book.worksheets.find{|sheet|sheet.name==name}
      unless sheet
        sheet = book.create_worksheet
        sheet.name = name
      end
      table.each_with_index do|record,row_index|
        record.each_with_index do|data,col_index|
          sheet[row_index,col_index] = data
        end
      end
    end
    book.write path
  end

end

module LXRoo
  def Excel输入 文档名,工作表名
    文档 = RooBot.new(文档名)
    文档.sheet(工作表名)
    return 文档.get_table
  end

  def Excel输出 文档名,多重表,模板路径,报告路径='report'
    if 模板路径.to_s.downcase.to_sym==:new
      文档 = RooBot.new
      文档.create_table("#{报告路径}/#{文档名}",多重表)
    else
      文档 = RooBot.new(模板路径)
      文档.set_table("#{报告路径}/#{文档名}",模板路径,多重表)
    end
  end
end
