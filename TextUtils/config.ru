#coding:utf-8
require "rack/cors"
require "roda"
require "TextUtils/textmind"

use Rack::Cors do
  allow do
    origins 'localhost:9200', '127.0.0.1:9200', /\Ahttp:\/\/192\.168\.0\.\d{1,3}(:\d+)?\z/ # Regular expressions can be used here
    resource '/file/list_all/', headers: 'x-domain-token'
    resource '/file/at/*', methods: [:get, :post, :delete, :put, :patch, :options, :head], headers: 'x-domain-token',
        expose: ['Some-Custom-Response-Header'], max_age: 600 # Headers to expose
  end

  allow do
    origins '*'
    resource '/public/*', methods: :get, headers: :any
    resource '/api/v1/*', methods: :get, headers: :any,
        if: proc {|env| env['HTTP_HOST'] == 'api.example.com'} # Only allow a request for a specific host
  end
end

$doc = {}

class App < Roda
  plugin :json_parser     # for recognizing json parameters
  plugin :request_headers # for checking request headers
  plugin :all_verbs       # for making all verbs available

  route do |r|
    r.on 'type' do
      # /type/int radix=2, text=100
      r.post 'int' do
        text = r.params['text']
        radix = r.params['radix'].to_i || 10
        text.int(radix).to_json
      end

      # /type/float tail=2, text=3.1415926
      r.post 'float' do
        text = r.params['text']
        tail = r.params['tail'].to_i || 2
        text.float(tail).to_json
      end

      # /type/precent tail=2, text=0.8675309
      r.post 'precent' do
        text = r.params['text']
        tail = r.params['tail'].to_i || 2
        text.precent(tail).to_json
      end

      # /type/text format=meta, text='hello world'
      r.post 'text' do
        text = r.params['text']
        format = r.params['format'].to_sym || :raw
        text.text(format).to_json
      end

      # /type/bool text=true
      r.post 'bool' do
        text = r.params['text']
        text.bool.to_json
      end
    end

    r.on 'text' do
      # /textt/head prefix=:prefix, strip=false, text=:file_head_sample
      r.post 'head' do
        text = r.params['text']
        prefix = r.params['prefix']
        strip = r.params['strip'] || false
        text.head?(prefix, strip).to_json
      end

      # /text/tail postfix=:postfix, strip=false, text=:file_tail_sample
      r.post 'tail' do
        text = r.params['text']
        postfix = r.params['postfix']
        strip = r.params['strip'] || false
        text.tail?(postfix, strip).to_json
      end

      # /text/include pattern=:pattern, text=:file_include_sample
      r.post 'include' do
        text = r.params['text']
        pattern = r.params['pattern']
        text.include?(pattern).to_json
      end

      # /text/empty text=:file_empty_sample
      r.post 'empty' do
        text = r.params['text']
        text.empty?.to_json
      end

      # /text/length text=:file_length_sample
      r.post 'length' do
        text = r.params['text']
        text.length.to_json
      end

      # /text/strip flag=:both, text=:file_strip_sample
      r.post 'strip' do
        text = r.params['text']
        flag = r.params['flag'].to_s.downcase.to_sym || :both
        result = flag==:both ? text.strip : flag==:left ? text.lstrip : flag==:right ? text.rstrip : text
        result.to_json
      end

      # /text/join attaches=:file_join_attaches_sample, text=:file_join_text_sample
      r.post 'join' do
        text = r.params['text']
        attaches = r.params['attaches'] || []
        text.join(attaches).to_json
      end

      # /text/+ oprand=:file_plus_oprand_sample, text=:file_plus_text_sample
      r.post '+' do
        text = r.params['text']
        oprand = r.params['oprand'] || ''
        (text + oprand).to_json
      end

      # /text/- oprand=:file_minus_oprand_sample, text=:file_minus_text_sample
      r.post '-' do
        text = r.params['text']
        oprand = r.params['oprand'] || ''
        (text - oprand).to_json
      end

      # /text/* oprand=:file_multiple_oprand_sample, text=:file_multiple_text_sample
      r.post '*' do
        text = r.params['text']
        oprand = (r.params['oprand'] || 1).to_s.to_i
        (text * oprand).to_json
      end

      # /text/split oprand=:file_devide_oprand_sample, text=:file_devide_text_sample
      r.post 'split' do
        text = r.params['text']
        oprand = r.params['oprand'] || ' ' # DIFF: '' <=> ' '
        (text / oprand).to_json
      end

      # /text/cut lidx=1, ridx=0, text=:file_cut_sample
      r.post 'cut' do
        text = r.params['text']
        lidx = r.params['lidx'] || 1
        ridx = r.params['ridx'] || 0
        text.cut(lidx, ridx).to_json
      end

      # /text/match pattens=:file_match_patterns_sample, mode=flag, text=:file_match_text_sample
      r.post 'match' do
        text = r.params['text']
        patterns = r.params['patterns'] || []
        mode = r.params['mode'].to_s.downcase.to_sym || :one
        ([:one, :all].include?(mode) ? (!patterns.first.to_s.empty? ? text.matches(patterns.first.to_s,mode) : text) : 
        text.matches(patterns,mode)).to_json
      end

      # /text/exchange oldtext=:file_exchg_otext_sample, newtext=:file_exchg_ntext_sample, repeat=all, text=:file_exchg_text_sample
      r.post 'exchange' do
        text = r.params['text']
        oldtext = r.params['oldtext']
        newtext = r.params['newtext']
        repeat = (r.params['repeat'] || 'all').to_s
        repeat = repeat.include?('all') ? repeat.to_sym : repeat.to_i
        text.exchange(oldtext, newtext, repeat).to_json
      end

      # /text/draw-lines preflag=:file_draw_prelines_example, postflag=:file_draw_postlines_example, text=:file_draw_textlines_sample
      r.post 'draw/lines' do
        text = r.params['text']
        preflag = Regexp.new r.params['preflag'].to_s
        postflag = Regexp.new r.params['postflag'].to_s
        rests, content = text.draw_lines(preflag, postflag)
        [content, rests].to_json
      end

      # /text/match/paragraph start=:file_match_start_para_sample, finish=:file_match_finish_para_sample, text=:file_match_text_para_sample
      r.post 'match/paragraph' do
        text = r.params['text']
        start = r.params['start'].to_s
        finish = r.params['finish'].to_s
        text.match_paragraph(start, finish).to_json
      end

      # /text/match/cascade start=:file_match_start_cas_sample, finish=:file_match_finish_cas_sample, text=:file_match_text_cas_sample
      r.post 'match/cascade' do
        text = r.params['text']
        start = r.params['start'].to_s
        finish = r.params['finish'].to_s
        text.match_cascade(start, finish).to_json
      end

      # /text/match/xml tag=:file_match_tag_sample, text=:file_match_tag_text_sample
      r.post 'match/xml' do
        text = r.params['text']
        tag = r.params['tag'].to_s
        text.match_xml(tag).to_json
      end
    end

    r.on 'list' do
      # /list/pop list=:file_pop_sample
      r.post 'pop' do
        list = r.params['list']
        list.pop.to_json
      end

      # /list/push item='item', list=:file_push_sample
      r.post 'push' do
        list = r.params['list']
        item = r.params['item']
        list.push(item).to_json
      end

      # /list/shift list=:file_shift_sample
      r.post 'shift' do
        list = r.params['list']
        list.shift.to_json
      end

      # /list/unshift item='item', list=:file_unshift_sample
      r.post 'unshift' do
        list = r.params['list']
        item = r.params['item']
        list.unshift(item).to_json
      end

      # /list/+ oprand=:file_listrand_plus_sample, list=:file_list_plus_sample
      r.post '+' do
        list = r.params['list']
        alt = r.params['oprand'] || []
        (list + alt).to_json
      end

      # /list/- oprand=:file_listrand_minux_sample, list=:file_list_minus_sample
      r.post '-' do
        list = r.params['list']
        alt = r.params['oprand'] || []
        (list - alt).to_json
      end

      # /list/catch oprand=:file_listrand_catch_sample, list=:file_list_catch_sample
      r.post 'catch' do
        list = r.params['list']
        alts = r.params['oprands'] || []
        list.catch(alts).to_json
      end

      # /list/sub lidx=1, ridx=0, text=:file_sub_sample
      r.post 'sub' do
        list = r.params['list']
        lidx = r.params['lidx'] || 1
        ridx = r.params['ridx'] || 0
        list.sub(lidx, ridx).to_json
      end

      # /list/match func=:file_match_func_sample, repeat=1, list=:file_match_func_list_sample
      r.post 'match' do
        list = r.params['list']
        repeat = r.params['repeat'] || 1
        func = eval(r.params['func'])
        list.match(repeat, &func).to_json
      end

      # /list/map func=:file_map_func_sample, list=:file_map_func_list_sample
      r.post 'map' do
        list = r.params['list']
        func = eval(r.params['func'])
        list.map(&func).to_json
      end

      # /list/reduce func=:file_reduce_func_sample, init="init-val:string" list=:file_reduce_func_list_sample
      r.post 'reduce' do
        list = r.params['list']
        func = eval(r.params['func'])
        sectors = r.params['init'].to_s.split(":")
        type = sectors.last.strip
        init = sectors[0..-2].join(':')
        iv = case type
          when 'text';    init.strip.to_s
          when 'integer'; init.strip.to_i
          when 'float';   init.strip.to_f
          when 'list';    eval(init)
          when 'tree';    eval(init)
        end
        list.reduce(iv,&func).to_json
      end
    end


    r.on 'tree' do
      # /tree/keys tree=:file_tree_keys_sample
      r.post 'keys' do
        tree = r.params['tree']
        tree.keys.to_json
      end

      # /tree/values tree=:file_tree_values_sample
      r.post 'values' do
        tree = r.params['tree']
        tree.values.to_json
      end

      # /tree/get key='key', tree=:file_tree_get_sample
      r.post 'get' do
        tree = r.params['tree']
        get_key = r.params['key'].to_s
        tree[get_key].to_json
      end

      # /tree/set key='key', val='val', tree=:file_tree_set_sample
      r.post 'set' do
        tree = r.params['tree']
        set_key = r.params['key']
        set_val = r.params['val']
        tree[set_key]=set_val
        tree.to_json
      end
      
      # /tree/+ oprand={}, tree=:file_tree_add_sample
      r.post '+' do
        tree = r.params['tree']
        alt = r.params['oprand'] # DIFF: "num" <=> num
        (tree + alt).to_json
      end
    end

  end
end

run App.freeze.app