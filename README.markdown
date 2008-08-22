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
 * font markup and weight (<b>, <strong>, ...)
 * text formatting (<sub>, <sup>, <ins>,<del>)

## Usage

`require 'clothblue'`

`text = ClothBlue.new("<b>Bold</b> <em>HTML</em>!")`

`text.to_markdown`

## Get Help

Feel free to contact me, or peruse the homepage.

 * http://craigjolicoeur.com/clothblue/
 * http://github.com/cpjolicoeur/clothblue/

## Acknowledgments

ClothBlue received inspiration from the [ClothRed library](http://clothred.rubyforge.org/) and the [Markdownify PHP library](http://milianw.de/projects/markdownify/).

[Markdown](http://daringfireball.com/projects/markdown) is, of course, written by [John Gruber](http://daringfireball.com).  [Markdown Extra](http://www.michelf.com/projects/php-markdown/extra/) support is also included.