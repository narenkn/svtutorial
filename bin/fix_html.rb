#! ruby

require 'nokogiri'

doc = Nokogiri::HTML(open(ARGV[0]))

doc_div = Nokogiri::XML::Node.new("div", doc)
doc_div['class'] = "book-page"

body = doc.at_css("body")
first_div_seen = false
second_div_seen = false
body.children.each { |child|
  if (! first_div_seen)
    first_div_seen = (("div" == child.name) and ("crosslinks" == child['class']))
    child.add_next_sibling(doc_div)
  elsif (! second_div_seen)
    second_div_seen = (("div" == child.name) and ("crosslinks" == child['class']))
    doc_div << child if ! second_div_seen
#    print child.name, ' ', child['class'], ' ', second_div_seen, "\n"
  end
}

if (! first_div_seen)
  body.children.each { |child|
#    puts child.name
#    if (! first_div_seen)
#      first_div_seen = ("div" == child.name)
#      child.add_previous_sibling(doc_div)
#      doc_div << child
#    else
      doc_div << child if ('book-page' != child['class'])
#    end
  }
#  body << doc_div
end

html = doc.to_html
puts html
