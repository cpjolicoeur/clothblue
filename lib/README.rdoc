= ClothBlue HTML 2 Markdown converter

== What it is

A script to convert HTML into Markdown markup for use, for example, with BlueCloth.


== Requirements

All you need is Ruby.

== Get it

Available as a gem on GitHub:

Or download from:

Or get the source:


== Features

This is alpha software, and only a few Markdown rules have been implemented yet:
 * font markup and weight (<b>, <strong>, ...)
 * text formatting (<sub>, <sup>, <ins>,<del>)

== Usage

require 'clothblue'

text = ClothBlue.new("<b>Bold</b> <em>HTML</em>!")
text.to_markdown

== Get Help

Feel free to contact me, or peruse the homepage.

 * http://craigjolicoeur.com/clothblue/
 * http://github.com/cpjolicoeur/clothblue/

== Acknowledgments

ClothBlue is heavily copied from the ClothRed library (http://clothred.rubyforge.org/).  Much thanks to
Phillip Gawlowski for the initial idea and code.  I basically just ported this HTML to Textile converter
to work with Markdown instead of Textile.  The format of the code and README docs are pretty much exact
clones as far as the format is concerned.