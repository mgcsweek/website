html = require "lapis.html"
config = (require "lapis.config").get!
import to_json from require "lapis.util"

class Error extends html.Widget
    content: =>
        raw @m[@status].error_page or "<p>Dogodila se greška!</p>"
        if config._name == 'development' or config._name == 'development-perftest'
            p class: "debug",
                @errors
