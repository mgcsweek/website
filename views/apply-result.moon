html = require "lapis.html"
import render_and_pass from require "utils"

class ApplyResult extends html.Widget
    content: =>
        apply_content = capture ->
            raw @resp.response
            ul ->
                if @resp.errors
                    for e in *@resp.errors
                        li -> raw e

        render_and_pass widget, "views.apply-base", { :apply_content }

