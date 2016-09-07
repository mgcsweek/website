html = require "lapis.html"

class About extends html.Widget
    content: =>
        if @nav
            @content_for "header", ->
                render "views.nav"

        if @footer
            @content_for "footer", ->
                render "views.footer"

        div { class: "parallax-heading", ["data-0"]: "background-position: 50% -30px", 
            ["data-top-bottom"]: "background-position: 50% -150px" }, ->
            h1 @m.heading

        section id: "about-text", class: "content-body", ->
            raw @m.content


