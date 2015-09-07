html = require "lapis.html"
import yield_error from require "lapis.application"

class Footer extends html.Widget
    content: =>
        footer id: "footer", ->
            div class: "left", ->
                raw @footer.text_left
            div class: "right", ->
                raw @footer.text_right



 
