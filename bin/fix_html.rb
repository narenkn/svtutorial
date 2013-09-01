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
    if child and child.child and ('next' ==  child.child['class'])
      div = Nokogiri::XML::Node.new('div', doc)
      div['class'] = 'crosslinks'
      div['id'] = 'nav'
      div << child.child
      body.children.first.add_previous_sibling(div)
      child.remove
    else
      doc_div << child if ('book-page' != child['class'])
    end
  }
end

## If 'crosslinks' then move it to unordered list
first_div_seen = false
link_name_fix = { "up" => "Title Page", "next" => "Next Chapter", "prev" => "Previous Chapter" }
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
        ## Add PDF download option
        li = Nokogiri::XML::Node.new("li", doc)
        a  = Nokogiri::XML::Node.new("a", doc)
        a.content = "Download PDF"
        a['href'] = "SV_through_examples.pdf"
        li << a
        ul << li
        ## Add Student Project
        li = Nokogiri::XML::Node.new("li", doc)
        a  = Nokogiri::XML::Node.new("a", doc)
        a.content = "College Projects"
        a['href'] = "college_projects.html"
        li << a
        ul << li
        # ## Donate
        # li = Nokogiri::XML::Node.new("li", doc)
        # a  = Nokogiri::XML::Node.new("a", doc)
        # a.content = "Donate"
        # a['href'] = "SV_through_examples.pdf"
        # li << a
        # ul << li
      }
      child << ul
      first_div_seen = true
    else
      child.remove
    end
  end
}

## What ever is body, change to body-main
#body_main = Nokogiri::XML::Node.new('div', doc)
#body_main['id'] = 'body_main'
#body.children.each { |child|
#    body_main << child
#}
#body << body_main

## Add right div
div = Nokogiri::XML::Node.new('div', doc)
div['id'] = 'rightlinks'
ul  = Nokogiri::XML::Node.new('ul',  doc)
ul['id'] = 'navigation'
li  = Nokogiri::XML::Node.new('li',  doc)
li.inner_html = '<a href="https://twitter.com/svtut2013"><img alt="Twitter" src="https://abs.twimg.com/a/1377795275/images/resources/twitter-bird-blue-on-white.png" height="25" width="25" title="Follow @svtut2013" /></a>'
ul << li
li = Nokogiri::XML::Node.new('li', doc)
li.inner_html = '<a href="http://feeds.feedburner.com/svtut2013"><img alt="Feeds" src="img/RSS.png" height="25" width="25" title="Get news updates via RSS" /></a></td>'
ul << li
li = Nokogiri::XML::Node.new('li', doc)
li.inner_html = '<a href="http://feedburner.google.com/fb/a/mailverify?uri=svtut2013&amp;loc=en_US"><img alt="Mail" src="img/mail.gif" height="25" width="25" title="Get news updates by email" /></a></td>'
ul << li
li = Nokogiri::XML::Node.new('li', doc)
li.inner_html = '<a href="http://www.facebook.com/pages/Svtut2013/419909814797134"><img alt="FB" src="img/fb.png" height="25" width="25" title="Become a fan on Facebook" /></a></td>'
ul << li
div << ul
body << div

## Print the modified HTML
html = doc.to_html
puts html
