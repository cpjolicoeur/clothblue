# test_lists.rb
# May 15, 2008
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

begin
  require "rubygems"
  require "clothblue"
rescue LoadError
  require "clothblue"
end

require 'test/unit'

class TestClothBlueLists < Test::Unit::TestCase
 
LISTS_TEST = [
    ["<ol>",""], ["</ol>","\n\n"], ["<li>","+  "], ["</li>","\n"], ["<ul>", ""], ["</ul>", "\n\n"]
  ]
  
  def test_lists
    LISTS_TEST.each do |html, markdown|
      test_html = ClothBlue.new(html)
      result = test_html.to_markdown
      assert_equal(markdown,result)
    end
  end
end