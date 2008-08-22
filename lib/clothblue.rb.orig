=begin rdoc
Provides the methods to convert HTML into Markdown.
*Please* *note*: ClothBlue creates UTF-8 output. To do so, it sets $KCODE to UTF-8. This will be globally available!
#--
TODO: enhance docs, as more methods come availlable
#++

Author:: Craig P Jolicoeur (mailto:cpjolicoeur@gmail.com)
Copyright:: Copyright (c) 2008 Craig P Jolicoeur
License:: MIT
=end

require 'cgi'
$KCODE = "U"

class ClothBlue < String
#--
  TEXT_FORMATTING = [
    ["<b>", "**"], ["</b>","**"], ["<em>","_"], ["</em>", "_"], ["<b>", "**"], 
    ["</b>", "**"], ["<code>", "`"], ["<i>","_"], ["</i>", "_"],
    ["</code>", "`"], ["<strong>", "**"], ["</strong>", "**"] 
  ]

  HEADINGS = [
    ["<h1>","# "], ["</h1>", " #\n\n"], ["<h2>","## "], ["</h2>", " ##\n\n"], 
    ["<h3>","### "], ["</h3>", " ###\n\n"], ["<h4>","#### "], ["</h4>", " ####\n\n"], 
    ["<h5>","##### "], ["</h5>", " #####\n\n"], ["<h6>","###### "], ["</h6>", " ######\n\n"]
  ]

  STRUCTURES = [
    ["<p>", "\n\n"],["</p>","\n\n"], ["<blockquote>", "> "], ["</blockquote>","\n"], 
    ["<br />", "\n"], ["<br>", "\n"]
  ]

  ENTITIES = [
    ["&#8220;", '"'], ["&#8221;", '"'], ["&#8212;", "--"], ["&#8212;", "--"], 
    ["&#8211;","-"], ["&#8230;", "..."], ["&#215;", " x "], ["&#8482;","(TM)"], 
    ["&#174;","(R)"], ["&#169;","(C)"], ["&#8217;", "'"]
  ]
  
  LISTS = [
    ["<ol>", ""], ["</ol>", "\n\n"], ["<ul>", ""], ["</ul>", "\n\n"], ["<li>", "+  "], ["</li>", "\n"]
  ]

  TABLES = [
    ["<table>","\n\n<table>"], ["</table>","</table>\n\n"]
  ]

  def initialize (html)
    super(html)
    @workingcopy = html
  end

#++  
  #Call all necessary methods to convert a string of HTML into Markdown markup.

  def to_markdown
    headings(@workingcopy)
    structure(@workingcopy)
    text_formatting(@workingcopy)
    lists(@workingcopy)
    entities(@workingcopy)
    tables(@workingcopy)
    @workingcopy = CGI::unescapeHTML(@workingcopy)
    @workingcopy
  end

#--
  #The conversion methods themselves are private.
  private

  def text_formatting(text)
    TEXT_FORMATTING.each do |htmltag, markdowntag|
      text.gsub!(htmltag, markdowntag)
    end
    text
  end


  def headings(text)
    HEADINGS.each do |htmltag, markdowntag|
      text.gsub!(htmltag, markdowntag)
    end
    text
  end
  
  
  def lists(text)
    LISTS.each do |htmltag, markdowntag|
      text.gsub!(htmltag, markdowntag)
    end
    text
  end


  def entities(text)
    ENTITIES.each do |htmlentity, markdownentity|
      text.gsub!(htmlentity, markdownentity)
    end
    text
  end


  def structure(text)
    STRUCTURES.each do |htmltag, markdowntag|
      text.gsub!(htmltag, markdowntag)
    end
    text
  end

  def tables(text)
    TABLES.each do |htmltag, markdowntag|
      text.gsub!(htmltag, markdowntag)
    end
    text
  end


  def css_styles(text)
    #TODO: Translate CSS-styles
    text
  end
#++
end # end class ClothBlue