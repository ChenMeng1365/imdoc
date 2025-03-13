
# TextMind Manual

| module                     | method          | short   | invoke | output              | params                           |
| -------------------------- | --------------- | ------- | ------ | ------------------- | -------------------------------- |
| TextAbstract::Type         | int             | i       | String | Integer             | radix=10                         |
| TextAbstract::Type         | float           | f       | String | Float               | tail=2                           |
| TextAbstract::Type         | precent         | p       | String | String              | tail=2                           |
| TextAbstract::Type         | text            | s       | String | String              | format=:raw\|:meta               |
| TextAbstract::Type         | bool            | b       | String | Boolean             | N/A                              |
| TextAbstract::TextOperator | head?           | head    | String | Boolean             | prefix, strip=false\|true        |
| TextAbstract::TextOperator | tail?           | tail    | String | Boolean             | postfix,strip=false\|true        |
| TextAbstract::TextOperator | include?        | include | String | Boolean             | text                             |
| TextAbstract::TextOperator | empty?          | empty   | String | Boolean             | N/A                              |
| TextAbstract::TextOperator | length          | length  | String | Integer             | N/A                              |
| TextAbstract::TextOperator | strip           | strip   | String | String              | N/A                              |
| TextAbstract::TextOperator | join            | join    | String | String              | text_list                        |
| TextAbstract::TextOperator | cut             | cut     | String | List                | index1, index2=0\|Integer        |
| TextAbstract::TextOperator | +               | +       | String | String              | text                             |
| TextAbstract::TextOperator | -               | -       | String | String              | text                             |
| TextAbstract::TextOperator | *               | *       | String | String              | text                             |
| TextAbstract::TextOperator | /               | /       | String | List                | text                             |
| TextAbstract::TextOperator | exchange        | replace | String | String              | text, newtext, num=:all\|Integer |
| TextAbstract::TextOperator | matches         | match   | String | RegExpr             | pattern, mode=:one\|:all\|:union |
| TextAbstract::TextOperator | draw_lines      | draw    | String | String, List        | preflag, postflag                |
| TextAbstract::TextOperator | match_paragraph | para    | String | List                | start, finish                    |
| TextAbstract::TextOperator | match_cascade   | casc    | String | List                | start, finish                    |
| TextAbstract::TextOperator | match_xml       | xml     | String | Tree                | tag                              |
| TextAbstract::ListOperator | pop             | pop     | List   | Item                | N/A                              |
| TextAbstract::ListOperator | push            | push    | List   | List                | text                             |
| TextAbstract::ListOperator | shift           | shift   | List   | Item                | N/A                              |
| TextAbstract::ListOperator | unshift         | unshift | List   | List                | text                             |
| TextAbstract::ListOperator | +               | +       | List   | List                | list                             |
| TextAbstract::ListOperator | -               | -       | List   | List                | list                             |
| TextAbstract::ListOperator | catch           | catch   | List   | List(List)          | list_list                        |
| TextAbstract::ListOperator | match           | match   | List   | Boolean\|Item\|List | num=1\|0\|:all\|Integer, &block  |
| TextAbstract::ListOperator | sub             | sub     | List   | List                | index1, index2=0\|Integer        |
| TextAbstract::ListOperator | map             | map     | List   | List                | &block                           |
| TextAbstract::ListOperator | reduce          | reduce  | List   | Item                | init, &block                     |
| TextAbstract::ListOperator | join            | join    | List   | Item                | init, &block                     |
| TextAbstract::TreeOperator | keys            | keys    | Tree   | List                | N/A                              |
| TextAbstract::TreeOperator | values          | values  | Tree   | List                | N/A                              |
| TextAbstract::TreeOperator | get             | get     | Tree   | Item                | key                              |
| TextAbstract::TreeOperator | set             | set     | Tree   | Item                | key, value                       |
| TextAbstract::TreeOperator | +               | +       | Tree   | Tree                | tree                             |



<!-- <pre>
# a = %Q|[A]--(s+ $1 $2)->[B]--(s.para $3 $4)->[C D]|
# b = %Q|[B] --(s.cut $5)-> [E]|

class Percent < Float
  def initializie num
    if num.instance_of?(Numeric)
      @num = num * 100.0
    elsif num.instance_of?(String)
      @num = num.to_f /100.0
    end
  end

  def to_s width=2
    (@num * 100 ).round(width).to_s+"%"
  end
end

a2 = Percent.new(0.5)

p a2.to_s


# __END__
# module TextAbstract
#   def type_list shortcut
#     {
#     'i'=>Integer,
#     'f'=>Float,
#     'p'=>Percent
#     }
#   end
# end


# z = '
# []--()->[]

end
</pre> -->