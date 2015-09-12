html = require "lapis.html"
import to_json from require "lapis.util"

class DefaultLayout extends html.Widget
    content: =>
        js = (require 'views.javascript')!.js
        print to_json(js)
        html_5 ->
            head -> 
                meta charset: "UTF-8"

                -- This enables web-scale mode, right?
                -- meta name: "viewport", content:"initial-scale=1"

                link href: "/static/style.css", rel: "stylesheet", type: "text/css"
                link rel: "shortcut icon", href: "/favicon.ico?v=2"
                title (@m and @m.title) or "MG CS Week"

            body id: @page_id, -> 
                @content_for "header"

                div id: "skrollr-body"
                main id: "content", ->
                    @content_for "inner"

                @content_for "footer"
                print to_json(js)
                for scrpt in *js
                    with scrpt
                        contents = .contents
                        .contents = nil
                        script scrpt, ->
                            raw contents

    upload: =>





