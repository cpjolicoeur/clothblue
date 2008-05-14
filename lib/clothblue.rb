=begin rdoc
Provides the methods to convert HTML into Markdown.
*Please* *note*: ClothBlue creates UTF-8 output. To do so, it sets $KCODE to UTF-8. This will be globally available!
#--
TODO: enhance docs, as more methods come availlable
#++

Author:: Craig P Jolicoeur (mailto:cpjolicoeur@gmail.com)
Copyright:: Copyright (c) 2008 Phillip Gawlowski
License:: MIT
=end

require 'cgi'
$KCODE = "U"

class ClothBlue < String
end