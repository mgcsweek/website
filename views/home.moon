html = require "lapis.html"

class Home extends html.Widget
    content: =>
        if @nav
            @content_for "header", render "views.nav"
        if @footer
            @content_for "footer", render "views.footer"
        

