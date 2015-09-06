html = require "lapis.html"

class DefaultLayout extends html.Widget
    content: =>
        html_5 ->
            head -> 
                meta charset: "UTF-8"

                -- This enables web-scale mode, right?
                meta name: "viewport", content:"initial-scale=1"

                link href: "/static/style.css", rel: "stylesheet", type: "text/css"
                title @title or "MG CS Week"

            body id: @page_id, -> 
                @content_for "header"
                section id: "content", ->
                    @content_for "inner"
                @content_for "footer"

