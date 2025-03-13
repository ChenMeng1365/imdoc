#coding:utf-8
$LOAD_PATH<<'.'
require 'endata'

EnData.load
EnData.parse

ruby = EnData.run EnData.source EnData.select name: 'code'
yaml = EnData.source EnData.select handler: 'yaml'
json = EnData.source EnData.select handler: :json

main = EnData.run do
  puts ruby
  pp yaml
  pp json
end

__END__
[a@endata ~]$ruby code
number = 1+1
迪兰 = rand.round(2)

[b@endata / ]$yaml hank
hank:
  - code
  - debug
  - deploy
hazel:
  blue
  
[c@endata /home/base]$ json coco
[{
  "dare": 100.0,
  "gale": [70,50,13,"outfit"]
}]