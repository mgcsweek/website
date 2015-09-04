html = require "lapis.html"
config = (require "lapis.config").get!

class Error extends html.Widget
    content: =>
        raw (@m and @m.error_page or "<p>Dogodila se greška!</p>")
        if config._name == 'development' or config._name == 'development-perftest'
            p class: "debug",
                @errors
