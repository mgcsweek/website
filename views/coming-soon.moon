html = require "lapis.html"

class ComingSoon extends html.Widget
    content: =>
        h1 class: "logotype", @m.title
        raw @m.teaser
