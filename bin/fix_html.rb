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

html = doc.to_html
puts html
