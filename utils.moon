html = require "lapis.html"

class Utils
    render_and_pass: (fn, widget_name, params) ->
        widget_obj = (require widget_name)!
        for k, v in pairs params
            widget_obj[k] = v

        fn widget_obj

