# test_structure.rb
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

class TestClothBlueStructures < Test::Unit::TestCase
 
  STRUCTURE_TEST = [
  ["<blockquote>blockquote</blockquote>","> blockquote\n"],
  ["<p>paragraph</p><p>another paragraph</p>", "\n\nparagraph\n\n\n\nanother paragraph\n\n"], 
  ["HTML page break<br>", "HTML page break\n"], ["XHTML page break<br />", "XHTML page break\n"]
  ]
  
  
  def test_structures
    STRUCTURE_TEST.each do |html, markdown|
      test_html = ClothBlue.new(html)
      result = test_html.to_markdown
      assert_equal(markdown,result)
    end
  end
end