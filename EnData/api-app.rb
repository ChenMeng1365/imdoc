#coding:utf-8

##################################################################################################################
# APPLICATION FOR WEBOOT API CALLING
##################################################################################################################
require 'weboot'

def cmds tabname
  return EnData.get_body(tabname).join(";")
end

def run tables, bind_table
  EnData::ApiRequest.run tables, bind_table
end

##################################################################################################################
#
# EnData::ApiRequest
#
# API:   template1 # an example of templates
# API:   bind      # single bind
# API:   send      # single send
# API:   make      # batch bind
# API:   handle    # batch send
# API:   run       # make + handle
#
# Step1: EnData::ApiRequest.make
# CASE:  table1 × table2 × ... >--(join)--> task_table + bind_table(ref,val) >--eval(binding)--> task_instances
# USE:   EnData.join_table() |> EnData.make_ref |> EnData.make_doc |> EnData::ApiRequest.bind
#
# Step2: EnData::ApiRequest.handle
# CASE:  task_instances >--(API CALLING)--> running_results
# USE:   EnData::ApiRequest.send
#
##################################################################################################################
module EnData
  module ApiRequest
    module_function

    def template1
%Q|POST ${path} HTTP/1.1
Host: ${server}
Accept: */*
Content-Type: application/json

{
  "protocol": "${protocol}",
  "host": "${device}",
  "user": "${access-key}",
  "app-key": "${app-key}",
  "cmds": "${operations}",
  "method": "${processes}"
}|
    end

    def bind options, template=EnData::ApiRequest.template1
      Replacement.init
      ['path','server','protocol','device','access-key','app-key','operations','processes'].each do|key|
        Replacement[key] = options[key].to_s
      end
      return TinText.instance(template)
    end

    def send context
      request = Weboot.request context
      response = Weboot.construct request
      report = JSON.parse(response['body'])['content']
    end

    def make tables, bind_table
      # Please don't join too much tables
      tasks = tables.shift
      tasks = EnData.join_table(tasks, tables.shift) until tables.empty?
      bind_table.each{|refname, reftext|tasks = EnData.make_ref(tasks, refname, reftext)}
      binds = EnData.make_doc(tasks)
      instances = binds.map{|binding|EnData::ApiRequest.bind binding} # with EnData::ApiRequest.template
    end

    def handle instances
      instances.map{|instance| EnData::ApiRequest.send instance}
    end

    def run tables, bind_table
      instances = EnData::ApiRequest.make tables, bind_table
      EnData::ApiRequest.handle(instances)
    end

  end
end