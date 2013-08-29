#! ruby

require 'nokogiri'

## The document in question
doc = Nokogiri::HTML(open(ARGV[0]))

## Remove meta tags those give away that we have generated
## from .tex files
head = doc.at_css("head")
head.children.each { |child|
  child.remove if (("meta" == child.name) or ("comment" == child.name))
##  puts child.name
}

## Create a div to encapsulate the book document
doc_div = Nokogiri::XML::Node.new("div", doc)
doc_div['class'] = "book-page"

## The document is enclosed by two 'crosslinks' div one on top
## and another on bottom. So, make the encapsulated div the parent
## of all divs between both the 'crosslinks' div.
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

## Only on the title page 'crosslinks' will not be found
## Hack to make that look better than nothing
if (! first_div_seen)
  body.children.each { |child|
      doc_div << child if ('book-page' != child['class'])
  }
end

## If 'crosslinks' then move it to unordered list
first_div_seen = false
link_name_fix = { "up" => "Title Page", "next" => "Next Chapter", "prev" => "Previous Chapter", "tail" => "End of Page" }
body.children.each { |child|
  if ('crosslinks' == child['class'])
    child['id'] = 'nav'
    if ! first_div_seen
      ul = Nokogiri::XML::Node.new("ul", doc)
      ul['id'] = 'navigation'
      child.children.each { |p|
        p.children.each { |a|
          if ('a' == a.name) and (link_name_fix.has_key?(a.content))
            li = Nokogiri::XML::Node.new("li", doc)
            a.content = link_name_fix[a.content]
            li << a
            ul << li
          else
            a.remove
          end
        }
        p.remove
      }
      child << ul
      first_div_seen = true
    else
      child.remove
    end
  end
}

## Print the modified HTML
html = doc.to_html
puts html
