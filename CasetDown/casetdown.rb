#coding:utf-8
#USE: XMLUtils/XmlUtils
#USE: TextUtils/text_abstract
#USE: Tabot/simtab

[
  'EnData/endata', 'EnData/endata-app', 'EnData/api-app',
  'Tabot/newtab', 'Tabot/simtab',
  'TextUtils/text_abstract', 'TextUtils/text_absparser', 'TextUtils/text_mind',
  'TinText/tum', 'TinText/cache', 'TinText/tin_text', 'TinText/tintext',
  'XMLUtils/XmlUtils',
  'CasetDown/casetter', 'CasetDown/casetdoc', 'CasetDown/casetcode', 'CasetDown/casetable'
].each{|lib|require lib}
