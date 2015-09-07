lapis = require "lapis"
config = (require "lapis.config").get!
content = require "content"

import after_dispatch from require "lapis.nginx.context"
import to_json from require "lapis.util"
import capture_errors, assert_error, yield_error from require "lapis.application"
safe_route = (fn) ->
    capture_errors {
        on_error: =>
            @app\error_handler self

        =>
            fn self
    }

class CSWeek extends lapis.Application
    layout: require "views.layout"

    error_handler: (context, code) =>
        code = code or 500
        context = context or self

        with context
            .m, err = content\get "error"
            if err then
                print "Could not load the error page (code #{code}): #{err}"
                .m = { }

            .m[code] = .m[code] or .m.default or { }
            .page_id = "error"
            .status = code
            .m.title = .m[code].title

        render: "error", status: code
        

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

    [home: "/"]: safe_route =>
        @page_id = "home"
        @m = assert_error content\get "home" 
        @lecturers = assert_error content\get "lecturers"
        @app\try_render "home", self

    [about: "/o-nedelji"]: safe_route =>
        @page_id = "about"
        @m = assert_error content\get "about"
        @app\try_render "about", self

    [lecturers: "/predavaci"]: safe_route =>
        @page_id = "lecturers"
        @m = assert_error content\get "lecturers_page"
        @lecturers = assert_error content\get "lecturers"
        @app\try_render "lecturers", self

    [lecturer: "/predavaci/:name"]: =>

    handle_404: =>
        @errors = "Route `#{self.req.parsed_url.path or 'unknown'}` not found"
        @app\error_handler self, 404


