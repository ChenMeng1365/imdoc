#coding:utf-8
$: << "../../../../suite" << "../../../../lib"
require 'caset/caset'
require 'Document/Tabot/ExcelBot'
include Caset
include MSOffice

scenario 'Excel操作' do # options = [ :bm_step | :bm_story ]
  before [:each] do # options = [:each | :all ]
  end
  
  ustep 0, "事前准备" do
    @template = "../../../../warehouse/fdb/template/excel2007.xlsx"
    @output = "bot.xlsx"
    @excel_bot = set_excel_bot
    @excel_bot.create @output,@template # 复制模板出来操作
  end

  ustep 1, "查看表单名称" do
    @excel_bot.connect @output 
    @excel_bot.select_sheet "sheet1"
    @excel_bot.sheet.name=="Sheet1" and puts '.'
  end
  
  ustep '2a', "操作单元格（坐标）" do
    @excel_bot.set_vector 1,3,"vf3"
    p @excel_bot.get_vector 1,3
  end
  
  ustep '2b',"操作单元格（编码）" do
    @excel_bot.select :c1
    #sleep 1
    @excel_bot.select "a1","b3"
    puts @excel_bot.contain 3,10
  end
  
  ustep 3,"...我写过这个???" do
    @excel_bot.add :chart
    0.step(180,5) do|angle|
      @excel_bot.set_rotation angle
      sleep 0.1
    end
  end

  ustep 4,"... 我是谁？我在干啥？我要得到啥？" do
    table = @excel_bot.get_table 4,6,3,2
    excel_contain = set_excel_bot :invisible
    excel_contain.add_workbook # 此处换成open uri，则※处就不会有问题
    excel_contain.select_sheet "sheet2"
    excel_contain.set_table table
    # (※)注意新Excel文档的save和ExcelOLE的save_as不同
    excel_contain.save_as "contain.xlsx" # ExcelOLE的save(_as)在此处执行
    excel_contain.quit # 新Excel文档的save在此时触发
  end

  ustep 999, "事后处理" do
    @excel_bot.save_as @output
    @excel_bot.quit
  end
  
  ustory "== operations ==" do
    run_steps [ 
      {id:0,desc:"事前准备"},
      {id:1,desc:"查看表单名称"}, 
      {id:'2a',desc:"操作单元格（坐标）"},
      {id:'2b',desc:"操作单元格（编码）"},
      {id:3,desc:"..."},
      #{id:4,desc:"... ..."},
      {id:999,desc:"事后处理"}
    ]
  end
  
  ustory "打包操作" do
    sleep 1
    Excel输出 "duplicate.xlsx",{'Sheet1'=>[[1,2,3],[4,5,6]]},"bot.xlsx"
    sleep 1
    (Excel输入 "duplicate.xlsx",'Sheet1',1,1,10,10).each do|record|
      puts record.join("|")
    end
  end

  after [:each] do # options = [:each | :all ]
  end
end

puts "","运行报告：",Caset.report
File.write "excelbot_doc.txt",Caset.document.join("\n")