# test_headings.rb
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

class TestClothBlueHeadings < Test::Unit::TestCase

  HEADING_TEST = [
  ["<h1>Heading 1</h1>","# Heading 1 #\n\n"], ["<h2>Heading 2</h2>", "## Heading 2 ##\n\n"],
  ["<h3>Heading 3</h3>", "### Heading 3 ###\n\n"], ["<h4>Heading 4</h4>", "#### Heading 4 ####\n\n"],
  ["<h5>Heading 5</h5>", "##### Heading 5 #####\n\n"], ["<h6>Heading 6</h6>", "###### Heading 6 ######\n\n"]
  ]


  def test_headings
    HEADING_TEST.each do |html, markdown|
      test_html = ClothBlue.new(html)
      result = test_html.to_markdown
      assert_equal(markdown,result)
    end
  end

  MIST_TEST = [
  ["<h1>Heading 1</h1><h2>Heading 2</h2>","# Heading 1 #\n\n## Heading 2 ##\n\n"],
  ]


  def test_mist_headings
    MIST_TEST.each do |html, markdown|
      test_html = ClothBlue.new(html)
      result = test_html.to_markdown
      assert_equal(markdown,result)
    end
  end

end
