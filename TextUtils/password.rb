#coding:utf-8

module Password
  @__setting__ = {
    min_length: 8,
    max_length: 128,
    alphabet: ('a'.ord..'z'.ord).map{|c|c.chr},
    captialbet: ('A'.ord..'Z'.ord).map{|c|c.chr},
    number: (0..9).map{|c|c.to_s},
    specific: %Q{~`!@#$%^&*()_-+=[]{}\|:;"'<,>.?/}.split(""),
    use: [:alphabet,:captialbet,:number,:specific],
  }
  
  def self.generate options={}
    setting = @__setting__.merge(options)
    length = setting[:length] || setting[:min_length] 
    (warn "设定密码长度小于正常范围(#{length}).";return nil) if length < 3
    (warn "设定密码长度超过了最大允许长度.";return nil)         if length > setting[:max_length]
    muster = setting[:use].map{|u|setting[u].shuffle.pop}
    pool = setting[:use].inject([]){|pool,sigil|setting[sigil] ? pool + setting[sigil] : pool}
    candicate = (length-setting[:use].size).times.map{pool.shuffle.pop}
    return (muster+candicate).shuffle.join
  end
  
  def self.safety_check context
    sigils = [:number,:alphabet,:captialbet,:specific]
    target = sigils.inject({}){|target,sigil| target[sigil] ||= []; target}
    context.split("").each{|c| sigils.each{|sigil| target[sigil] << c if @__setting__[sigil].include?(c)} }
    return ( sigils.select{|sigil|target[sigil].size>0}.size>=3 ? true : false )
  end
  
end