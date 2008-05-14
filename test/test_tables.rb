# test_tables.rb
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

class TestClothBlueTables < Test::Unit::TestCase
 
  TABLES_TEST = [
    ["<table><tr><td>name</td><td>age</td><td>sex</td></tr><tr><td>joan</td><td>24</td><td>f</td></tr></table>",
    "\n\n<table><tr><td>name</td><td>age</td><td>sex</td></tr><tr><td>joan</td><td>24</td><td>f</td></tr></table>\n\n"]
  ]
  
  def test_entities
    TABLES_TEST.each do |html, markdown|
      test_html = ClothBlue.new(html)
      result = test_html.to_markdown
      assert_equal(markdown,result)
    end
  end
end