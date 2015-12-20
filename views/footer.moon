html = require "lapis.html"
import yield_error from require "lapis.application"

class Footer extends html.Widget
    content: =>
        footer id: "footer", ->
            div class: "left", ->
                raw @footer.text_left
            div class: "right", ->
                raw @footer.text_right

            div class: "social-icons", ->
                ul ->
                    li class: "facebook", ->
                        a href: @footer.icons.facebook.url, ->
                            span class: "icon"
                            span class: "url", @footer.icons.facebook.text

                    li class: "youtube", ->
                        a href: @footer.icons.youtube.url, ->
                            span class: "icon"
                            span class: "url", @footer.icons.youtube.text

