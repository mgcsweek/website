lapis = require "lapis"
config = (require "lapis.config").get!
content = require "content"

import after_dispatch from require "lapis.nginx.context"
import to_json from require "lapis.util"
import capture_errors, assert_error, yield_error from require "lapis.application"

class CSWeek extends lapis.Application
    layout: require "views.layout"

    error_handler: =>
        @m = content\get "error" or { }
        @page_id = "error"
        return render: "error", status: 500
        
    try_render: (template, context) =>
        context = context or self
        with context 
            .nav = assert_error content\get "nav"
            .footer = assert_error content\get "footer"
        render: template

    @before_filter =>

        if #[n for n in *{'production-perftest', 'development-perftest'} when n == config._name] > 0
            after_dispatch ->
                print to_json(ngx.ctx.performance)

    "/": capture_errors {
        on_error: =>
             @app.error_handler self

        =>
            @page_id = "home"
            @m = assert_error content\get "coming_soon" 
            @app\try_render "home", self
    }

