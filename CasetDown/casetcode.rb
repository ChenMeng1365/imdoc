#coding:utf-8

module CasetDown
  module_function

  def textchange text
    text.gsub('&gt;','>').gsub('&lt;','<')
  end

  def wrap_output text, id, tag='output'
    output_start = "```shell\n##{tag}>#{id}"
    output_finish= "```"
    return [output_start, text, output_finish].join("\n")
  end

  def search_output text, id, tag='output'
    # [TODO] REFACTORING for recognition between '#output>path' and '#output> path'
    output_start = "```shell\n##{tag}>#{id}"
    output_finish= "```"
    match = TextAbstract.match_paragraph text, output_start, output_finish
    return match.map{|m|[output_start, m, output_finish].join}
  end

  def magic_head code
    states = textchange(code[:code]).split("\n")
    interpreter = code[:class]
    script = states.find{|s|s[0..4]=='#src>'||s[0..7]=='#script>'}.to_s.split('>')[1]
    interpreter = script if script # :default

    namespace = states.find{|s|s[0..3]=='#ns>'||s[0..10]=='#namespace>'}.to_s.split('>')[1] || :ns
    config = states.find{|s|s[0..5]=='#conf>'||s[0..7]=='#config>'}.to_s.split('>')[1] || :conf
    target = states.find{|s|s[0..4]=='#dst>'||s[0..7]=='#target>'}.to_s.split('>')[1]

    flow = states.find{|s|s[0..5]=='#flow>'||s[0..5]=='#step>'}.to_s.split('>')[1] || :flow
    segment = states.find{|s|s[0..4]=='#seg>'||s[0..8]=='#segment>'}.to_s.split('>')[1] || :seg

    input = states.find{|s|s[0..3]=='#in>'||s[0..6]=='#input>'}.to_s.split('>')[1] || :in
    output = states.find{|s|s[0..4]=='#out>'||s[0..7]=='#output>'}.to_s.split('>')[1] || :out

    [interpreter, namespace, target, flow, segment, input, output].each{|tag|tag.strip! if tag.instance_of?(String)}

    rows = if row = states.find{|s|s[0..4]=='#row>'}.to_s.split('>')[1]
      row.gsub('~','..').split(',').map{|r|eval(r)}
    else
      :rows
    end
    cols = if col = states.find{|s|s[0..4]=='#col>'}.to_s.split('>')[1]
      col.split(',').map{|c|
        c.split('').inject(true){|f,chr|
          f&&(('0'..'9').to_a+['-','~']).include?(chr)
        } ? eval(c.gsub('~','..')) : c.strip
      }
    else
      :cols
    end

    return interpreter, namespace, config, target, flow, segment, input, output, rows, cols
  end

  def search_codes cds
    codes = CasetDown::Check.all(cds).select{|cd|cd[:name]=='code'}

    table = codes.inject({}) do|table, code|
      interpreter, namespace, config, target, flow, segment, input, output, rows, cols = magic_head code

      content = textchange(code[:code]).split("\n")[1..-1].select{|s|
        !['#ns>','#in>'].include?(s[0..3]) &&
        !['#out>','#src>','#dst>','#seg>','#row>','#col>'].include?(s[0..4]) &&
        !['#flow>','#step>','#conf>'].include?(s[0..5]) &&
        !['#input>'].include?(s[0..6]) &&
        !['#script>','#target>','#output>','#config>'].include?(s[0..7]) &&
        !['#segment>'].include?(s[0..8]) &&
        !['#namespace>'].include?(s[0..10])
      }.join("\n")
      table[[code.object_id, interpreter, namespace, config, target, [rows,cols], flow, segment, input, output]] = content
      table
    end
    return table
  end

  def run cds
    table = CasetDown.search_codes(cds)
    $_tmp_global_ = {}
    $_scr_head_ = ['#coding:utf-8','["EnData/endata","EnData/endata-app","TinText/tum","TinText/cache","TinText/tin_text","TinText/tintext","Tabot/newtab","Tabot/simtab"].each{|mod|require(mod)}'].join("\n")
    result = {}
    table.each do|key, text|
      oid, interpreter, ns, conf, target, range, flow, seg, input, output = key
      unless conf==:conf # 注意全局配置累积生效，所以有先后顺序
        $_tmp_global_.merge!(
          (File.exist?(conf)           ? YAML.load(File.read conf)           : {}) ||
          (File.exist?("#{conf}.yml")  ? YAML.load(File.read "#{conf}.yml")  : {}) ||
          (File.exist?("#{conf}.yaml") ? YAML.load(File.read "#{conf}.yaml") : {})
        )
        $_scr_tail_ = "\n__END__\n[global@endata ~]$ruby global\n#{$_tmp_global_.to_s}"
        $_erl_tail_ = $_tmp_global_.empty? ? '' : ToErlang.fact('global', (ToErlang.hash($_tmp_global_)) )
      end
      if interpreter=='shell' || interpreter==:default
        if RUBY_PLATFORM.include?('mingw')
        else
          File.write "./~tmp.sh",text
          running = `bash ./~tmp.sh`
          File.delete "./~tmp.sh"
        end
      elsif interpreter=='ruby'
        File.write "./~tmp.rb","#{$_scr_head_}\n\n#{text}\n\n#{$_scr_tail_}"
        running = `ruby ./~tmp.rb`
        File.delete "./~tmp.rb"
      elsif interpreter=='erlang' || interpreter=='erl'
        File.write "./_tmp.erl","-module(_tmp).\n-export([main/1]).\n\n#{text}\n\n#{$_erl_tail_}\n\nfact(UnknownMessage)->\n  io:format(\"~p\",[UnknownMessage])."
        running = `escript ./_tmp.erl`
        File.delete "./_tmp.erl"
      elsif interpreter=='python3' || interpreter=='python'
        File.write "./~tmp.py",text
        running = `python ./~tmp.py`
        File.delete "./~tmp.py"
      elsif interpreter=='lms'
        running = `lms "#{text}"`
      elsif interpreter=='lmx'
        running = `lmx "#{text}"`
      else
      end
      result[input] = running
    end
    return result
  end

  def run_to_file cds,option={stream: nil, data: nil, fact: nil,file:[]} # empty, :input, :output, :all
    $_tmp_global_ = {}
    $_scr_head_ = ['#coding:utf-8','["EnData/endata","EnData/endata-app","TinText/tum","TinText/cache","TinText/tin_text","TinText/tintext","Tabot/newtab","Tabot/simtab"].each{|mod|require(mod)}'].join("\n")
    $_scr_tail_ = option[:data] ? option[:data] : ''
    $_erl_tail_ = option[:fact] ? option[:fact] : ''

    table = CasetDown.search_codes(cds)
    result = {}
    table.each do|key, text|
      oid, interpreter, ns, conf, target, range, flow, seg, input, output = key
      unless conf==:conf # 注意全局配置累积生效，所以有先后顺序
        $_tmp_global_.merge!(
          (File.exist?(conf)           ? YAML.load(File.read conf)           : {}) ||
          (File.exist?("#{conf}.yml")  ? YAML.load(File.read "#{conf}.yml")  : {}) ||
          (File.exist?("#{conf}.yaml") ? YAML.load(File.read "#{conf}.yaml") : {})
        )
        $_scr_tail_ = $_scr_tail_.empty? ? "\n__END__\n[global@endata ~]$ruby global\n#{$_tmp_global_.to_s}" : "#{$_scr_tail_}\n[global@endata ~]$ruby global\n#{$_tmp_global_.to_s}"
        $_erl_tail_ = $_tmp_global_.empty? ? $_erl_tail_ : $_erl_tail_+"\n\n"+ToErlang.fact('global', (ToErlang.hash($_tmp_global_)) )
      end
      if interpreter==:default
        # NOTHING
      elsif interpreter=='shell' || interpreter=='bash'
        if RUBY_PLATFORM.include?('mingw')
        else
          File.write "./~tmp.sh",text
          running = `bash ./~tmp.sh`
          File.delete "./~tmp.sh" unless option[:file].include?(:debug)
        end
      elsif interpreter=='ruby'
        File.write "./~tmp.rb","#{$_scr_head_}\n\n#{text}\n\n#{$_scr_tail_}"
        running = `ruby ./~tmp.rb`
        File.delete "./~tmp.rb" unless option[:file].include?(:debug)
      elsif interpreter=='erlang' || interpreter=='erl'
        File.write "./_tmp.erl","-module(_tmp).\n-export([main/1]).\n\n#{text}\n\n#{$_erl_tail_}\n\nfact(UnknownMessage)->\n  io:format(\"~p\",[UnknownMessage])."
        running = `escript ./_tmp.erl`
        File.delete "./_tmp.erl" unless option[:file].include?(:debug)
      elsif interpreter=='python3' || interpreter=='python'
        File.write "./~tmp.py",text
        running = `python ./~tmp.py`
        File.delete "./~tmp.py" unless option[:file].include?(:debug)
      elsif interpreter=='lms'
        running = `lms "#{text}"`
      elsif interpreter=='lmx'
        running = `lmx "#{text}"`
      else
      end
      result[input] = running
      File.write input, text if !(option[:file] & [:input, :all]).empty? && input.instance_of?(String)
    end

    origin_text = option[:stream] || cds[:doc].text
    result.each do|input, running| # input == output
      File.write input, running if !(option[:file] & [:output, :all]).empty? && input.instance_of?(String)
      origins = CasetDown.search_output(origin_text, input)
      wrapped = CasetDown.wrap_output(running,input)
      if origins.empty?
        origins = CasetDown.search_output(origin_text, input, 'out')
        wrapped = CasetDown.wrap_output(running,input, 'out')
      end
      origins.each do|origin|
        # [TODO] 无法解决不同后缀的前置匹配替换问题，待修复
        origin_text = origin_text.gsub(origin, wrapped)
      end
    end

    if option[:file].include?(:rendfile)
      if option[:file].include?(:preview)
        prvw = cds[:path].split('.')
        prvw.insert(-2,'preview')
        File.write prvw.join('.'), origin_text
      else
        pazz = cds[:path].split('.')
        pazz.insert(-2,Time.new.strftime("%Y%m%d%H%M%S"))
        File.write pazz.join('.'), origin_text
      end
    end
    return origin_text
  end
end

module ToErlang
	module_function

	def table data
		fields = data.first
		erlang_data = data.drop(1).map do |row|
			row_data = fields.zip(row).map do |field, value|
				"{\"#{field}\", \"#{value}\"}"
			end.join(",")
			"{#{row_data}}"
		end
		"[#{erlang_data.join(", ")}]"
	end

  def hash data
    "{"+data.map{|k,v|"{\"#{k}\", \"#{v}\"}"}.join(",")+"}"
  end

	def fact name, body
		"fact(\"#{name.to_s}\")->\n  #{body};"
	end
end