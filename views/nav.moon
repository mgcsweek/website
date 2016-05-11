html = require "lapis.html"
import yield_error from require "lapis.application"

class Nav extends html.Widget
    content: =>
        header ->
            h1 { ["data-0"]: "opacity: 1", ["data-top-bottom"]: "opacity: 0" }, ->
                a href: (@url_for 'home'), @nav.header_text

            if @nav.items
                nav ->
                    ul ->
                        for v in *@nav.items
                            li id: v.id, ->
                                a href: v.href, v.text


