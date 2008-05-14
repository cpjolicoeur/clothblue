# test_entities.rb
# May 14, 2008
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

begin
  require "rubygems"
  require "clothblue"
rescue LoadError 
  require "clothblue"
end

require 'test/unit'

class TestClothBlueEntities < Test::Unit::TestCase
 
  ENTITIES_TEST = [
    ["&#8220;", '"'], ["&#8221;", '"'], ["&#8212;", "--"], ["&#8212;", "--"], 
    ["&#8211;","-"], ["&#8230;", "..."], ["&#215;", " x "], ["&#8482;","(TM)"], 
    ["&#174;","(R)"], ["&#169;","(C)"], ["&#8217;", "'"]
  ]
  
  def test_entities
    ENTITIES_TEST.each do |html, markdown|
      test_html = ClothBlue.new(html)
      result = test_html.to_markdown
      assert_equal(markdown,result)
    end
  end
end
