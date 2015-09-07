html = require "lapis.html"
import yield_error from require "lapis.application"

class Footer extends html.Widget
    content: =>
        footer id: "footer", ->
            div ->
                raw @footer.text_left
            div ->
                raw @footer.text_right



 
