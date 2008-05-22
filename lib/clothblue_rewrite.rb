require 'parsehtml/parsehtml'

class ClothBlue #:nodoc:
  
  # Constants
  MDFY_LINKS_EACH_PARAGRAPH = false
  MDFY_BODYWIDTH = false
  MDFY_KEEPHTML = true
  
  # tags which can be handled by markdown
  IS_MARKDOWNABLE = {
    'p' => [],
    'ul' => [],
    'ol' => [],
    'li' => [],
    'br' => [],
    'blockquote' => [],
    'code' => [],
    'pre' => [],
    'a' => [{'href' => 'required'}, {'title' => 'optional'}],
    'strong' => [],
    'b' => [],
    'em' => [],
    'i' => [],
    'img' => [{'src' => 'required'}, {'alt' => 'optional'}, {'title' => 'optional'}],
    'h1' => [],
    'h2' => [],
    'h3' => [],
    'h4' => [],
    'h5' => [],
    'h6' => [],
    'hr' => []
  }
  
  # html tags to be ignored (content will be parsed)
  IGNORE = []
  
  # html tags to be dropped (content will not be parsed!)
  DROP = %w(script head style form)
  
  # Markdown indents which could be wrapped
  WRAPPABLE_INDENTS = [
    '\*   ',  # ul
    '\d.  ',  # ol
    '\d\d. ', # ol
    '> ',     # blockquote
    ''        # p
  ]
  
  # list of chars which have to be escaped in normal text
  # TODO: what's with block chars/ sequences at the beginning of a block?
  ESCAPE_IN_TEXT = [
		{'([-*_])([ ]{0,2}\1){2,}' => '\\\\$0|'},      # hr
		{'\*\*([^*\s]+)\*\*' => '\*\*$1\*\*'},         # strong
		{'\*([^*\s]+)\*' => '\*$1\*'},                 # em
		{'__(?! |_)(.+)(?!<_| )__' => '\_\_$1\_\_'},   # em
		{'_(?! |_)(.+)(?!<_| )_' => '\_$1\_'},         # em
		{'`(.+)`' => '\`$1\`'},                        # code
		{'\[(.+)\](\s*\()' => '\[$1\]$2'},             # links: [text] (url) => [text\] (url)
		{'\[(.+)\](\s*)\[(.*)\]' => '\[$1\]$2\[$3\]'}, # links: [text][id] => [text\][id\]
  ]
  
  # parseHTML parser
  attr_reader :parser
  
  # markdown output
  attr_reader :output
  
  # stack with tags which were not converted to html
  @not_converted = []
  attr_reader :not_converted
  
  # skip conversion to markdown
  @skip_conversion = false
  attr_reader :skip_conversion
  
  # keep html tags which cannot be converted to markdown
  @keep_html = false
  attr_reader :keep_html
  
  # wrap output, set to 0 to skip wrapping
  @body_width = 0
  attr_reader :body_width
  
  # minimum body width
  @min_body_width = 25
  attr_reader :min_body_width
  
  # display links after each paragraph
  @links_after_each_paragraph = false
  attr_reader :links_after_each_paragraph
  
  # whether last processed node was a block tag or not
  @last_was_block_tag = false
  attr_reader :last_was_block_tag
  
  # name of last closed tag
  @last_closed_tag = ''
  attr_reader :last_closed_tag
  
  # Constructor
  def initialize(links_after_each_paragraph = MDFY_LINKS_EACH_PARAGRAPH, body_width = MDFY_BODYWIDTH, keep_html = MDFY_KEEPHTML)
    @links_after_each_paragraph = links_after_each_paragraph
    @keep_html = keep_html
    @body_width = (body_width > @min_body_width) ? body_width.to_i : false
    
    @parser = ParseHTML.new
    
    search, replace = [], []
  end
  
  # parse an HTML string
  def parse_string(html)
    @parser.html = html
    @output = parse
    return @output
  end
  
  # iterate through the nodes and decide what to do with the current node
  def parse
    @output = ''
    # drop tags  
  end
    
  end
  
end