html = require "lapis.html"
import yield_error from require "lapis.application"

class Nav extends html.Widget
    content: =>
        header ->
            h1 @nav.header_text

    

