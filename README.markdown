# ClothBlue 

HTML to Markdown library

## What it is

A script to convert HTML into Markdown markup for use, for example, with BlueCloth.

## Requirements

All you need is Ruby.

## Get it

Available as a gem on GitHub: (coming soon)

Or download from: http://clothblue.rubyforge.org

Or get the source: http://github.com/cpjolicoeur/clothblue

## Features

This is beta software, and only a few Markdown rules have been implemented yet:

* font markup and weight (&lt;b&gt;, &lt;strong&gt;, ...)
* text formatting (&lt;sub&gt;, &lt;sup&gt;, &lt;ins&gt;,&lt;del&gt;)

## Usage

`require 'clothblue'`

`text = ClothBlue.new("<b>Bold</b> <em>HTML</em>!")`

`text.to_markdown`

## Get Help

Feel free to contact me, or view the homepage.

* http://craigjolicoeur.com/clothblue/
* http://github.com/cpjolicoeur/clothblue/

## Developers

* [Craig P Jolicoeur](http://craigjolicoeur.com) - http://github.com/cpjolicoeur

## License

MIT License

Copyright (c) 2008 Craig P Jolicoeur

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

## Acknowledgments

ClothBlue received inspiration from the [ClothRed library](http://clothred.rubyforge.org/) and the [Markdownify PHP library](http://milianw.de/projects/markdownify/).

[Markdown](http://daringfireball.com/projects/markdown) is, of course, written by [John Gruber](http://daringfireball.com).  Michel Fortin's [Markdown Extra](http://www.michelf.com/projects/php-markdown/extra/) support is also included.