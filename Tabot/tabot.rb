#coding:utf-8

if RUBY_PLATFORM.include?('linux') && $tabot
  require 'Tabot/RooBot'
elsif RUBY_PLATFORM.include?('mingw') && $tabot
  require 'Tabot/ExcelBot'
end
require 'Tabot/newtab'
require 'Tabot/simtab'