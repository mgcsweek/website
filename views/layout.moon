html = require "lapis.html"
import to_json from require "lapis.util"

class DefaultLayout extends html.Widget
    content: =>
        js = (require 'views.javascript')!.js
        html_5 ->
            head ->
                meta charset: "UTF-8"
                meta property:"og:image", content:"/static/images/ni.png?v=9"

                -- This enables web-scale mode, right?
                meta name: "viewport", content:"initial-scale=1"

                link href: "/static/style.css?v=9", rel: "stylesheet", type: "text/css"
                link rel: "apple-touch-icon", sizes: "180x180", href: "/apple-touch-icon.png?v=9"
                link rel: "icon", type: "image/png", href: "/favicon-32x32.png?v=9", sizes: "32x32"
                link rel: "icon", type: "image/png", href: "/favicon-16x16.png?v=9", sizes: "16x16"
                link rel: "manifest", href: "/manifest.json?v=9"
                link rel: "mask-icon", color: "89a7f4", href: "/safari-pinned-tab.svg?v=9"
                link rel: "shortcut icon", href: "/favicon.ico?v=9"
                meta name: "theme-color", content: "#89a7f4"

                title (@m and @m.title) or "MG CS Week"

            body id: @page_id, ->
                @content_for "header"

                div id: "skrollr-body"
                main id: "content", ->
                    @content_for "inner"

                @content_for "footer"
                for scrpt in *js
                    with scrpt
                        contents = .contents
                        .contents = nil
                        script scrpt, ->
                            raw contents

    upload: =>





