html = require "lapis.html"

class Utils
    render_and_pass: (fn, widget_name, params) ->
        widget_obj = (require widget_name)!
        for k, v in pairs params
            widget_obj[k] = v

        fn widget_obj

    json_requested: (req) ->
        split = (require "utils").split
        return false if not req or not req.res or not req.res.req or not req.res.req.headers

        hdr = req.res.req.headers
        return false if not hdr.accept

        val = hdr.accept
        val = val\match '(.*);' if val\find ';'
        spl = split val, ','
        return false if #spl < 1

        spl[1] = spl[1]\gsub "^%s*(.-)%s*$", "%1"
        return true if spl[1] == 'application/json'
        false

    split: (str, sep) ->
        return false if not sep or sep == '' or not str

        r = {}
        n, init = 1, 1

        while true
            s, e = str\find sep, init, true
            break if not s

            r[#r + 1] = str\sub init, s - 1
            init = e + 1
            n += 1

        r[#r + 1] = if init <= str\len!
            str\sub init
        else
            ""

        r, n

