html = require "lapis.html"

class Apply extends html.Widget
    content: =>
        if @nav
            @content_for "header", ->
                render "views.nav"

        if @footer
            @content_for "footer", ->
                render "views.footer"

        @content_for "scripts", ->
            script src: "https://cdnjs.cloudflare.com/ajax/libs/skrollr/0.6.30/skrollr.min.js", defer: "defer"
            script src: "/static/main.js", defer: "defer"

        div { class: "parallax-heading", ["data-0"]: "background-position: 0px -440px",
            ["data-top-bottom"]: "background-position: 0px -150px" }, ->
            h1 @m.heading

        section class: "content-body", ->
            h1 "Da li znaš da dodaš gas"
            p "Pusti ritam pusti bas"
            h1 "Noćas naš je celi grad"
            p "Gledaj kako rolam sad"


