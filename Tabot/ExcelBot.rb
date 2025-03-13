# coding:utf-8
# for microsoft office
require 'win32ole'
require 'FileUtils'

class ExcelBot
  attr_accessor :table
  
  def initialize tag = true
    @excel = WIN32OLE.new("Excel.Application")
    @excel.visible = tag
    @table = []
  end

  # 添加工作本类型
  # flag = nil #黙认EXCEL文件(有3个工作表)
  # flag = 1 #单工作表
  # flag = 2 #图表
  # flag = 3 #宏表
  # flag = 4 #国际通用宏表
  # flag = 5 #与默认的相同
  # flag = 6 #与1同
  # flag = 7 #对话框
  def add_workbook flag=nil
    @workbook = @excel.Workbooks.add flag
  end
  
  def add type
    if type.to_s.downcase == "chart"
      @chart = @excel.Charts.Add()
      @chart.type = -4100 # -4100 is the value for the Excel constant xl3DColumn.
    end
  end
  
  def create pathname,temp_path
    FileUtils.copy(temp_path,pathname)
  end
  
  def connect uri
    if uri.include?('.xls')
      @path = uri if File.exist?(uri)
      @path = uri.encode('GBK') if File.exist?(uri.encode('GBK'))
    else
      @path = uri+".xlsx" if File.exist?(uri+".xlsx")
      @path = uri+".xls" if File.exist?(uri+".xls")
      @path = (uri+".xlsx").encode('GBK') if File.exist?(uri+".xlsx").encode('GBK')
      @path = (uri+".xls").encode('GBK') if File.exist?(uri+".xls").encode('GBK')
    end
    @workbook = @excel.Workbooks.open @path
    return @path
  end
  
  def select_sheet sheet_name
    unless @workbook==nil
      @current_sheet = @workbook.Worksheets(sheet_name.encode("GBK")) 
    end
  end
  
  def sheet
    @current_sheet ||= @excel.activesheet
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
  
  def set_vector row,column,value
    unless @current_sheet==nil
      @current_sheet.Range("#{latin(column)}#{row}").value = value
      return value
    else
      raise "未选择工作表"
    end
  end
  
  def get_vector row,column
    unless @current_sheet==nil
      return @current_sheet.Range("#{latin(column)}#{row}").value
    else
      raise "未选择工作表"
    end
  end
  
  def saved
    @workbook.saved = true
  end
  
  def save_as path
    @excel.save Dir.pwd+path.encode("GBK") # 不要覆盖自身，要用绝对路径
  end

  def quit
    @excel.ActiveWorkbook.Close(0)
    @excel.quit
  end
  
  def contain row=1000,column=26
    table = ""
    row.times.each do|yid|
      table << "|"
      column.times.each{|xid|table << "#{get_vector(yid+1,xid+1)}|"}
      table << "\n"
    end
    return table
  end
  
  # get table from another excel_bot
  def set_table table
    table.each_with_index do|line,index|
      line.each_with_index{|content,idx|set_vector(index+1,idx+1,content)}
    end
  end
  
  def get_table y,x,length,width
    @table = []
    length.times.each do|col_shift|
      line = []
      width.times.each{|row_shift| line << get_vector(y+col_shift,x+row_shift)}
      @table << line
    end
    return @table
  end
  
  def select st,ed=nil
    if ed == nil
      @excel.Range("#{st}").select
    else
      @excel.Range("#{st}:#{ed}").select
    end
  end
  
  def set_rotation angle
    @chart.rotation = angle
  end
end

module MSOffice
  def set_excel_bot visible=:visible
    bool =(visible == :invisible ? false : true)
    ExcelBot.new bool
  end
  
  def absolute_path
    File.dirname(__FILE__)
  end
  
  def relative_path
    # require 'pathname'
    Pathname.new(".").realpath.to_s.encode('utf-8')
    # Dir.pwd.encode('utf-8')
  end

  def Excel输入 文档名,工作表名,起始行,起始列,行数,列数
    excel_bot = set_excel_bot :invisible
    excel_bot.connect 文档名
    excel_bot.select_sheet 工作表名
    table = excel_bot.get_table 起始行,起始列,行数,列数
    excel_bot.quit
    return table
  end

  def Excel输出 文档文件名,多重表,模板路径,报告路径='.'
    后缀 = 文档文件名.include?(".xlsx") ? ".xlsx" : ".xls"
    文档名 = 文档文件名.split(".")[0..-2].join(".")
    warn "操作期间请不要打开Excel"
    excel_bot = set_excel_bot :invisible
    文档路径 = "#{报告路径}/#{文档名}#{后缀}" # 命名不能用方括号
    
    unless File.exist? 文档路径.encode("GBK")
      excel_bot.create 文档路径.encode("GBK"),模板路径
    end
    excel_bot.connect (文档路径)#.encode("GBK")
    
    多重表.each do|handler,table|
      excel_bot.select_sheet handler
      excel_bot.set_table table
    end
    
    excel_bot.save_as 文档名
    excel_bot.quit
  end
end
