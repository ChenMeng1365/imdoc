#coding:utf-8
$:.unshift "../../lib/AAA"
require 'rspec'
require 'password'

describe Password do
  context "保密有效性" do
    it "密码长度可配置，且不小于8个字符" do
      password = Password.generate() # default {length: 8}
      password.size.should be >= 8
    end
    
    it "密码字符可配置，至少包含数字，大写，小写和特殊字符中的三种" do
      password = Password.generate(use: [:alphabet,:captialbet,:number])
      Password.safety_check(password).should be true 
      password = Password.generate(use: [:alphabet,:number,:specific])
      Password.safety_check(password).should be true 
      password = Password.generate(use: [:alphabet,:captialbet,:specific])
      Password.safety_check(password).should be true 
      password = Password.generate(use: [:captialbet,:number,:specific])
      Password.safety_check(password).should be true 
    end

    it "密码设置应避免键盘序密码，键盘序指相邻键盘等，如asd" do
      pending ;raise "todo"
    end
  end
  
  context "系统验证性" do
    it "密码应与账号名无关，不能包含帐号的完整字符或大小写变换" do
      pending ;raise "todo"
    end

    it "密码有效期设置，到期不修改密码，拒绝登陆，一般设置90天" do
      pending ;raise "todo"
    end

    it "设置密码修改不能重复的历史数目" do
      pending ;raise "todo"
    end

    it "设置帐号连续N天未登录，自动锁定帐号功能、由管理员解锁，一般设置90天" do
      pending ;raise "todo"
    end
  end
end