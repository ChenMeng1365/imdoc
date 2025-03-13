#coding:utf-8
import os
import sys
import xlrd
import json
import pandas as pd
from pandas import DataFrame

# read_excel excel=>mem 
# read_text  text=>mem

# write_text  mem=>text
# write_excel mem=>excel

# trans_excel text=>mem=>excel
# trans_text  excel=>mem=>text

def read_excel(pathname,sheetname='Sheet1'):
  if os.path.exists(pathname):
    dataframe = pd.read_excel(pathname,sheetname)
    return dataframe
  else:
    None

def read_text(pathname):
  if os.path.exists(pathname):
    dataframe =  pd.read_table(pathname)
    return dataframe
  else:
    return None

def write_excel(pathname,dataframe,tablename='Sheet1'):
  dataframe.to_excel(pathname,sheet_name=tablename,index=False)

def write_text(pathname,dataframe,tablename='Sheet1'):
  filepath = pathname.replace(".xlsx","").replace(".xls","")+"_"+tablename+".txt"
  dataframe.to_csv(filepath,sep='\t',index=False)

def trans_excel(pathname,sheetname='Sheet1'):
  if os.path.exists(pathname):
    dataframe = read_text(pathname)
    write_excel(pathname.replace(".txt",".xlsx"),dataframe,sheetname)
    return 'ok'
  else:
    return None

def trans_text(pathname,sheetnames=[]):
  excel = xlrd.open_workbook(pathname)
  for sheet_name in excel.sheet_names():
    if len(sheetnames)==0 or (sheet_name in sheetnames):
      table = read_excel(pathname,sheet_name)
      write_text(pathname,table,sheet_name)

# cmd tool
the_pathname = sys.argv[-1]
if "pantab.py" not in the_pathname:
  if ".xlsx" in the_pathname:
    trans_text(the_pathname,[])
  elif ".xls" in the_pathname:
    trans_text(the_pathname,[])
  elif ".txt" in the_pathname:
    trans_excel(the_pathname)
else:
  print("pantab loading...")