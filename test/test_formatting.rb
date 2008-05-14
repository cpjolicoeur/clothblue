# test_formatting.rb
# May 15, 2008
#

#circumventing a require Problem:
$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

begin
  require "rubygems"
  require "clothblue"
rescue LoadError
  require "clothblue"
end

require "test/unit"

class TestClothBlueFormatting <  Test::Unit::TestCase
  
  FORMATTING_STRINGS = [
    ["<b>bold</b>","**bold**"], ["<strong>strong</strong>", "**strong**"], 
    ["<em>emphasized</em>", "_emphasized_"],["<i>italics</i>", "_italics_"], 
    ["<code>ClothBlue#to_markdown</code>", "`ClothBlue#to_markdown`"]
  ]
 
  def test_textformatting
    FORMATTING_STRINGS.each do |html, markdown|
      test_html = ClothBlue.new(html)
      result = test_html.to_markdown
      assert_equal(markdown,result)
    end
  end

end