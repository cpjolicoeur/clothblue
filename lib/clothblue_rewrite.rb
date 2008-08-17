# require 'html/document'
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
  @output = ''
  attr_accessor :output
  
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
  
  # list of chars which have to be escaped in normal text
  @escape_in_text = {}
  attr_reader :escape_in_text
  
  # number of linebreaks before next inline output
  @linebreaks = 0
  attr_accessor :linebreaks
  
  # stores current buffer
  @buffer = []
  attr_accessor :buffer
  
  # current indentation
  @indent = ''
  attr_accessor :indent
  
  # node stack, e.g. for <a> and <abbr> tags
  @stack = {}
  attr_accessor :stack
  
  # Constructor
  def initialize(text = '', links_after_each_paragraph = MDFY_LINKS_EACH_PARAGRAPH, body_width = MDFY_BODYWIDTH, keep_html = MDFY_KEEPHTML)
    @links_after_each_paragraph = links_after_each_paragraph
    @keep_html = keep_html
    @body_width = (body_width > @min_body_width) ? body_width.to_i : false
    
    @parser = HTML::Tokenizer.new(text)
    
    @search, @replace = [], []
    ESCAPE_IN_TEXT.each do |s,r|
      @search << '/(?<!\\\)/' + s + '/U'
      @replace << r
    end
    
    @escape_in_text = {'search' => @search, 'replace' => @replace}
  end
  
  # parse an HTML string
  def parse_string
    # @parser.html = html ## -> if we passed it in
    parse
    return @output
  end
  
  # iterate through the nodes and decide what to do with the current node
  def parse
    @output = ''
    # drop tags that are in the DROP list
    # TODO: implement dropping of @drop tags
    
    while token = @parser.next_node
      case @parser.node_type
      when 'doctype', 'pi', 'comment'
        if (@keep_html)
          flush_linebreaks
          out(@parser.node)
          set_linebreaks(2)
        end
      when 'text'
        handle_text
      when 'tag'
        next if IGNORE.include?(@parser.tag_name)
        flush_linebreaks if (@parser.is_start_tag)
        if (@skip_conversion)
          is_markdownable # update notConverted
          handle_tag_to_text
          next
        end
        @parser.html = @parser.html.lstrip if (!@parser.keep_whitespace && @parser.is_block_element && @parser.is_start_tag)
        if (is_markdownable)
          if (@parser.is_block_element && @parser.is_start_tag && !@last_was_block_tag && !@output.empty?)
            if (!@buffer.empty?)
              str = @buffer[@buffer.size - 1]
            else
              str = @output
            end
            if (str.slice((@indent.size - 1) * -1) != "\n#{@indent}")
              str << "\n" + @indent
            end
            func = "handle_tag_#{@parser.tag_name}"
            self.send(func)
            
            if (@links_after_each_paragraph && @parser.is_block_element && !@parser.is_start_tag)
              flush_stacked
            end
            if(!@parser.is_start_tag)
              @last_closed_tag = @parser.tag_name
            end
          end
        else
          handle_tag_to_text
          @last_closed_tag = ''
        end
      else
        # TODO: trigger error for invalid node type
      end # end case
      
      @last_was_block_tag = (@parser.node_type == 'tag' && @parser.is_start_tag && @parser.is_block_element)
    end # end while
    
    ### cleanup
    tmp = @output.gsub('&gt;', '>')
    tmp = tmp.gsub('&amp;', '&')
    @output = tmp.rstrip
    # end parsing, flush stacked tags
    flush_stacked
    @stack = {}
<<<<<<< HEAD:lib/clothblue_rewrite.rb
=======
  end
  
  # check if current tag can be converted to Markdown
  def is_markdownable 
    return false  unless (IS_MARKDOWNABLE.include?(@parser.tag_name))
    
    if (@parser.is_start_tag)
      ret = true
      if (@keep_html)
        diff = @parser.tag_attributes.reject { |a| @parser.tag_name.include?(a) }
        ret = false unless diff.empty? # non markdownable attributes given
      end
      if (ret)
        IS_MARKDOWNABLE.each do |attr, type|
          if ((type == 'required') && @parser.tag_attributes[attr].nil?)
            # required Markdown attribute not given
            ret = false
            break
          end
        end
      end
      unless (ret)
        @not_converted << (@parser.tag_name + '::' + @parser.open_tags.join('/'))
      end
      return ret
    else
      if (!@not_converted.empty? && (@not_converted.last == (@parser.tag_name + '::' + @parser.open_tags.join('/'))))
        @not_converted.pop
        return false
      end
      return true
    end
  end
  
  # flush enqued linebreaks
  def flush_linebreaks
    if ((@linebreaks > 0) && !@output.empty?)
      out("\n" * @linebreaks, true)
    end
    @linebreaks = 0
  end
  
  # output all stacked tags
  def flush_stacked
    # # links
    # foreach ($this->stack as $tag => $a) {
    #   if (!empty($a)) {
    #     call_user_func(array(&$this, 'flushStacked_'.$tag));
    #   }
    # }
  end

  # set number of line breaks before next start tag
  def set_linebreaks(number)
    @linebreaks = number if (@linebreaks < number)
  end
  
  # append string to the correct var, either directly to
  # @output or to the current buffers
  def out(put = '', nowrap = false)
    return if put.empty?
    
    if (!@buffer.empty?)
      @buffer.last << put
    else
      if ((@body_width > 0) && !@parser.keep_whitespace) # wrap lines
        # get last line
        pos = @output.index("\n")
        line = pos ? @output.slice(pos, @output.size - pos) : @output
      end
      
      if (nowrap)
        if ((put[0,1] != "\n") && (line.size + put.size) > @body_width)
          @output << "\n#{indent(put)}"
        else
          @output << put
        end
        return
      else
        put << "\n" # make sure we get all lines in the while below
        line_len = line.size
        while (pos = put.index("\n"))
          put_line = put.slice(1, pos+1)
          put_len = put_line.size
          put = put.slice(pos+1, put.size - pos)
          if (line_len + put_len < @body_width)
            @output << put_line
            line_len = put_len
          else
            # $split = preg_split('#^(.{0,'.($this->bodyWidth - $lineLen).'})\b#', $putLine, 2, PREG_SPLIT_OFFSET_CAPTURE | PREG_SPLIT_DELIM_CAPTURE);
            # $this->output .= rtrim($split[1][0])."\n".$this->indent.$this->wordwrap(ltrim($split[2][0]), $this->bodyWidth, "\n".$this->indent, false);
          end
        end # end while
      end
      @output = @output(0, -1)
      return
    else
      @output << put
    end
>>>>>>> b6201584759afcc6f24a557ef9312597bd63f98f:lib/clothblue_rewrite.rb
  end
  
<<<<<<< HEAD:lib/clothblue_rewrite.rb
  # check if current tag can be converted to Markdown
  def is_markdownable 
    return false  unless (IS_MARKDOWNABLE.include?(@parser.tag_name))
=======
  # indent next output (start tag) or unindent (end tag)
  def indent(str, output = true)
    if (@parser.is_start_tag)
      @indent << str
      out(str, true) if @output
    else
      @indent = @indent.slice(0, (str.size * -1))
    end
  end 
   
  # handle plain text
  def handle_text 
    if (has_parent('pre') && @parser.node.index("\n"))
      @parser.node.gsub!("\n", "\n#{@indent}")
    end
    if (!has_parent('code') && !has_parent('pre'))
      # entity decode
      decode(@parser.node)
      if (!@skip_conversion)
        # escape some chars in normal text
        @parser.node.gsub!(@escape_in_text['search'], @escape_in_text['replace'])
      end
    else
      @parser.node.gsub!(['&quot;', '&apos'], ['"', '\''])
    end
    out(@parser.node)
    @last_closed_tag = ''
  end 
  
  # handle non-Markdownable tags
  def handle_tag_to_text
    if (!@keep_html)
      set_linebreaks(2) if (!@parser.is_start_tag && @parser.is_block_element)
    else
      # dont convert to markdown inside this tag
      # TODO: markdown extra
      if (!@parser.is_empty_tag)
        if (@parser.is_start_tag)
          unless (@skip_conversion)
            @skip_conversion = @parser.tag_name + '::' + @parser.open_tags.join('/')
          end
        else
          if (@skip_conversion == (@parser.tag_name + '::' + @parser.open_tags.join('/'))
            @skip_conversion = false
          end
        end
      end # end !@parser.is_empty_tag
      
      if (@parser.is_block_element)
        if (@parser.is_start_tag)
          if (%w(ins del).include?(parent))
            # looks like ins or del are block elements now
            out("\n", true)
            indent('  ')
          end
          if (@parser.tag_name != 'pre')
            out(@parser.node + "\n" + @indent)
            @parser.is_empty_tag ? set_linebreaks(1) : indent('  ')
            @parser.html = @parser.html.lstrip
          else
            # dont indent inside <pre> tags
            out(@parser.node)
            @static_indent = @indent
            @indent = ''
          end
        else
          @output = rstrip(@output) unless @parser.keep_whitespace
          if (@parser.tag_name != 'pre')
            indent('  ')
            out("\n" + @indent + @parser.node)
          else
            # reset indentation
            out(@parser.node)
            @indent = @static_indent
          end
          
          if (%w(ins del).include?(parent))
            # ins or del was block element
            out("\n")
            indent('  ')
          end
          
          @parser.tag_name == 'li' ? set_linebreaks(1) : set_linebreaks(2)
        end
      else
        out(@parser.node)
      end
      
      if (%w(code pre).include?(@parser.tag_name))
        if (@parser.is_start_tag)
          buffer
        else
          # add stuff so cleanup just reverses this
          tmp = unbugger.gsub('&gt;', '&amp;gt;')
          out(tmp.gsub('&lt;', '&amp;lt;'))
        end
      end
    end
  end
  
  # get tag name of direct parent tag
  def parent
    @parser.open_tags.last
  end
  
  # check if current not has a tag as parent (somewhere, not just the direct parent)
  def has_parent(tag)
    @parser.open_tags.include?(tag)
  end
  
  # add current node to the stack (this only stores the attributes)
  def stack
    @stack[@parser.tag_name] = [] if (@stack[@parser.tag_name].nil?)
    @stack[@parser.tag_name] << @parser.tag_attributes
  end
  
  # remove current tag from stack
  def unstack
    if (@stack[@parser.tag_name].nil? || !@stack[@parser.tag_name].is_a?(Array))
      # TODO: trigger and error
      raise "somebody set us up the bomb"
    end
    @stack[@parser.tag_name].pop
  end
  
  # get last stacked element of type tag
  def get_stacked(tag)
    @stack[tag][@stack[tag].size-1]
  end
  
  # buffer next parser output until unbuffer is called
  def buffer
    @buffer << ''
  end
  
  # end current buffer and return buffered output
  def unbuffer
    @buffer.pop
  end
  
  # wordwrap for utf8 encoded strings
  def wordwrap(str, width, brk, cut = false)
>>>>>>> b6201584759afcc6f24a557ef9312597bd63f98f:lib/clothblue_rewrite.rb
    
    if (@parser.is_start_tag)
      ret = true
      if (@keep_html)
        diff = @parser.tag_attributes.reject { |a| @parser.tag_name.include?(a) }
        ret = false unless diff.empty? # non markdownable attributes given
      end
      if (ret)
        IS_MARKDOWNABLE.each do |attr, type|
          if ((type == 'required') && @parser.tag_attributes[attr].nil?)
            # required Markdown attribute not given
            ret = false
            break
          end
        end
      end
      unless (ret)
        @not_converted << (@parser.tag_name + '::' + @parser.open_tags.join('/'))
      end
      return ret
    else
      if (!@not_converted.empty? && (@not_converted.last == (@parser.tag_name + '::' + @parser.open_tags.join('/'))))
        @not_converted.pop
        return false
      end
      return true
    end
  end
  
<<<<<<< HEAD:lib/clothblue_rewrite.rb
  # flush enqued linebreaks
  def flush_linebreaks
    if ((@linebreaks > 0) && !@output.empty?)
      out("\n" * @linebreaks, true)
    end
    @linebreaks = 0
  end
  
  # output all stacked tags
  def flush_stacked
    # # links
    # foreach ($this->stack as $tag => $a) {
    #   if (!empty($a)) {
    #     call_user_func(array(&$this, 'flushStacked_'.$tag));
    #   }
    # }
  end

  # set number of line breaks before next start tag
  def set_linebreaks(number)
    @linebreaks = number if (@linebreaks < number)
  end
  
  # append string to the correct var, either directly to
  # @output or to the current buffers
  def out(put = '', nowrap = false)
    return if put.empty?
    
    if (!@buffer.empty?)
      @buffer.last << put
    else
      if ((@body_width > 0) && !@parser.keep_whitespace) # wrap lines
        # get last line
        pos = @output.index("\n")
        line = pos ? @output.slice(pos, @output.size - pos) : @output
      end
      
      if (nowrap)
        if ((put[0,1] != "\n") && (line.size + put.size) > @body_width)
          @output << "\n#{indent(put)}"
        else
          @output << put
        end
        return
      else
        put << "\n" # make sure we get all lines in the while below
        line_len = line.size
        while (pos = put.index("\n"))
          put_line = put.slice(1, pos+1)
          put_len = put_line.size
          put = put.slice(pos+1, put.size - pos)
          if (line_len + put_len < @body_width)
            @output << put_line
            line_len = put_len
          else
            # $split = preg_split('#^(.{0,'.($this->bodyWidth - $lineLen).'})\b#', $putLine, 2, PREG_SPLIT_OFFSET_CAPTURE | PREG_SPLIT_DELIM_CAPTURE);
            # $this->output .= rtrim($split[1][0])."\n".$this->indent.$this->wordwrap(ltrim($split[2][0]), $this->bodyWidth, "\n".$this->indent, false);
          end
        end # end while
      end
      @output = @output(0, -1)
      return
    else
      @output << put
    end
  end
  
  # indent next output (start tag) or unindent (end tag)
  def indent(str, output = true)
    if (@parser.is_start_tag)
      @indent << str
      out(str, true) if @output
    else
      @indent = @indent.slice(0, (str.size * -1))
    end
  end 
   
  # handle plain text
  def handle_text 
    if (has_parent('pre') && @parser.node.index("\n"))
      @parser.node.gsub!("\n", "\n#{@indent}")
    end
    if (!has_parent('code') && !has_parent('pre'))
      # entity decode
      decode(@parser.node)
      if (!@skip_conversion)
        # escape some chars in normal text
        @parser.node.gsub!(@escape_in_text['search'], @escape_in_text['replace'])
      end
    else
      @parser.node.gsub!(['&quot;', '&apos'], ['"', '\''])
    end
    out(@parser.node)
    @last_closed_tag = ''
  end 
  
  # handle non-Markdownable tags
  def handle_tag_to_text
    if (!@keep_html)
      set_linebreaks(2) if (!@parser.is_start_tag && @parser.is_block_element)
    else
      # dont convert to markdown inside this tag
      # TODO: markdown extra
      if (!@parser.is_empty_tag)
        if (@parser.is_start_tag)
          unless (@skip_conversion)
            @skip_conversion = @parser.tag_name + '::' + @parser.open_tags.join('/')
          end
        else
          if (@skip_conversion == (@parser.tag_name + '::' + @parser.open_tags.join('/'))
            @skip_conversion = false
          end
        end
      end # end !@parser.is_empty_tag
      
      if (@parser.is_block_element)
        if (@parser.is_start_tag)
          if (%w(ins del).include?(parent))
            # looks like ins or del are block elements now
            out("\n", true)
            indent('  ')
          end
          if (@parser.tag_name != 'pre')
            out(@parser.node + "\n" + @indent)
            @parser.is_empty_tag ? set_linebreaks(1) : indent('  ')
            @parser.html = @parser.html.lstrip
          else
            # dont indent inside <pre> tags
            out(@parser.node)
            @static_indent = @indent
            @indent = ''
          end
        else
          @output = rstrip(@output) unless @parser.keep_whitespace
          if (@parser.tag_name != 'pre')
            indent('  ')
            out("\n" + @indent + @parser.node)
          else
            # reset indentation
            out(@parser.node)
            @indent = @static_indent
          end
          
          if (%w(ins del).include?(parent))
            # ins or del was block element
            out("\n")
            indent('  ')
          end
          
          @parser.tag_name == 'li' ? set_linebreaks(1) : set_linebreaks(2)
        end
      else
        out(@parser.node)
      end
      
      if (%w(code pre).include?(@parser.tag_name))
        if (@parser.is_start_tag)
          buffer
        else
          # add stuff so cleanup just reverses this
          tmp = unbugger.gsub('&gt;', '&amp;gt;')
          out(tmp.gsub('&lt;', '&amp;lt;'))
        end
      end
    end
  end
  
  # get tag name of direct parent tag
  def parent
    @parser.open_tags.last
  end
  
  # check if current not has a tag as parent (somewhere, not just the direct parent)
  def has_parent(tag)
    @parser.open_tags.include?(tag)
  end
  
  # add current node to the stack (this only stores the attributes)
  def stack
    @stack[@parser.tag_name] = [] if (@stack[@parser.tag_name].nil?)
    @stack[@parser.tag_name] << @parser.tag_attributes
  end
  
  # remove current tag from stack
  def unstack
    if (@stack[@parser.tag_name].nil? || !@stack[@parser.tag_name].is_a?(Array))
      # TODO: trigger and error
      raise "somebody set us up the bomb"
    end
    @stack[@parser.tag_name].pop
  end
  
  # get last stacked element of type tag
  def get_stacked(tag)
    @stack[tag][@stack[tag].size-1]
  end
  
  # buffer next parser output until unbuffer is called
  def buffer
    @buffer << ''
  end
  
  # end current buffer and return buffered output
  def unbuffer
    @buffer.pop
  end
  
  # wordwrap for utf8 encoded strings
  def wordwrap(str, width, brk, cut = false)
    # TODO: implement wordwrap for utf8 code
  end
  
=======
>>>>>>> b6201584759afcc6f24a557ef9312597bd63f98f:lib/clothblue_rewrite.rb
  # decode email address
  def decode(text, quoted_style = '')
    # TODO: implement decode method

    # @author derernst@gmx.ch <http://www.php.net/manual/en/function.html-entity-decode.php#68536>
    # @author Milian Wolff <http://milianw.de>
    # if (version_compare(PHP_VERSION, '5', '>=')) {
    #   # UTF-8 is only supported in PHP 5.x.x and above
    #   $text = html_entity_decode($text, $quote_style, 'UTF-8');
    # } else {
    #   if (function_exists('html_entity_decode')) {
    #     $text = html_entity_decode($text, $quote_style, 'ISO-8859-1');
    #   } else {
    #     static $trans_tbl;
    #     if (!isset($trans_tbl)) {
    #       $trans_tbl = array_flip(get_html_translation_table(HTML_ENTITIES, $quote_style));
    #     }
    #     $text = strtr($text, $trans_tbl);
    #   }
    #   $text = preg_replace_callback('~&#x([0-9a-f]+);~i', array(&$this, '_decode_hex'), $text);
    #   $text = preg_replace_callback('~&#(\d{2,5});~', array(&$this, '_decode_numeric'), $text);
    # }
    # return $text;
  end

end