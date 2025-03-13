#coding:utf-8
import xlrd
import xlwt
import os
import sys
import json

# read_excel excel=>mem 
# read_text  text=>mem
# read_json json=>mem

# write_text  mem=>text
# write_excel mem=>excel
# write_json mem=>json

# trans_excel text=>mem=>excel
# trans_text  excel=>mem=>text
# trans_json excel=>mem=>json

def read_excel(pathname,sheetname='Sheet1'):
  excel = xlrd.open_workbook(pathname)
  if (sheetname in excel.sheet_names()):
    table = []
    sheet = excel.sheet_by_name(sheetname)
    for index in range(sheet.nrows):
      row = sheet.row_values(index)
      table.append(row)
    return table
  else:
    return None

def write_excel(pathname,table,tablename='Sheet1'):
  workbook = xlwt.Workbook()
  worksheet = workbook.add_sheet(tablename)
  nrows = len(table)
  ncols = 0
  for row in table:
    if ncols <= len(row):
      ncols = len(row)
  for row in range(nrows):
    record = table[row]
    for col in range(len(record)):
      worksheet.write(row, col, label = table[row][col])
  workbook.save(pathname)

def read_text(pathname):
  if os.path.exists(pathname):
    with open(pathname, 'r') as file:
      list = file.readlines()
    table = []
    for row in list:
      table.append(row.split("\t"))
    return table
  else:
    return None

def write_text(pathname,table,sheetname='Sheet1'):
  if table:
    content = []
    for row in table:
      record = [str(item) for item in row]
      content.append("\t".join(record))
    file = open(pathname.replace(".xlsx","").replace(".xls","")+"_"+sheetname+".txt","w")
    file.write("\n".join(content))
    file.close

def read_json(pathname):
  with open(pathname,'r') as load_f:
    doc = json.load(load_f)
  return doc

def write_json(pathname,table,sheetname='Sheet1'):
  with open(pathname.replace(".xlsx","").replace(".xls","")+"_"+sheetname+".json","w") as dump_f:
    json.dump(table,dump_f,indent=2,sort_keys=True, ensure_ascii=False)

def trans_text(pathname,sheetnames=[]):
  excel = xlrd.open_workbook(pathname)
  for sheet_name in excel.sheet_names():
    if len(sheetnames)==0 or (sheet_name in sheetnames):
      table = read_excel(pathname,sheet_name)
      write_text(pathname,table,sheet_name)

def trans_excel(pathname,sheetname='Sheet1'):
  table = read_text(pathname)
  if table:
    write_excel(pathname.replace(".txt","")+".xls",table,sheetname)

def trans_json(pathname,sheetnames=[]):
  excel = xlrd.open_workbook(pathname)
  for sheet_name in excel.sheet_names():
    if len(sheetnames)==0 or (sheet_name in sheetnames):
      table = read_excel(pathname,sheet_name)
      write_json(pathname,table,sheet_name)

# cmd tool
the_pathname = sys.argv[-1]
if "tabot.py" not in the_pathname:
  if ".xlsx" in the_pathname:
    trans_text(the_pathname,[])
    # trans_json(the_pathname,[])
  elif ".xls" in the_pathname:
    trans_text(the_pathname,[])
    # trans_json(the_pathname,[])
  elif ".txt" in the_pathname:
    trans_excel(the_pathname)
else:
  print("tabot loading...")
