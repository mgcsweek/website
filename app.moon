lapis = require "lapis"
config = (require "lapis.config").get!
content = require "content"
logger = require "lapis.logging"
console = require "lapis.console" if config._name == 'development' or config._name == 'development-perftest'

import after_dispatch from require "lapis.nginx.context"
import to_json from require "lapis.util"
import capture_errors, assert_error, yield_error from require "lapis.application"

class CSWeek extends lapis.Application
    layout: require "views.layout"
    error_page: require "views.error"

    handle_error: (err, trace, code = 500) =>
        r = @app.Request @app, @req, @res

        with r
            .m, errpg = content\get "error"
            if errpg then
                .m = { }
                .m[code] = "Could not load the error page (code #{code}): #{errpg}<br/>When handling #{err}<br/>#{trace}"

            .m[code] = .m[code] or .m.default or { }
            .page_id = "error"
            .status = code
            .error = err
            .traceback = trace
            .m.title = .m[code].title

            \write {
                status: code
                content_type: "text/html"
                render: "error"
            }
            \render!
            logger.request r
        r

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

    [home: "/"]: =>
        @page_id = "home"
        @m = assert_error content\get "home" 
        @lecturers = assert_error content\get "lecturers"
        @app\try_render "home", self

    [about: "/o-nedelji"]: =>
        @page_id = "about"
        @m = assert_error content\get "about"
        @app\try_render "about", self

    [lecturers: "/predavaci"]: =>
        @page_id = "lecturers"
        @m = assert_error content\get "lecturers_page"
        @lecturers = assert_error content\get "lecturers"
        @app\try_render "lecturers", self

    [lecturer: "/predavaci/:name"]: =>
        @lecturers_page = assert_error content\get "lecturers_page"
        @page_id = "lecturer"
        lecturers = assert_error content\get "lecturers"
        results = [l for l in *lecturers when l.id == @params.name]
        if #results > 1
            yield_error "Multiple lecturer id's found for id `#{@params.name}`"
        else if #results == 0
            @app.handle_error self, "No such lecturer: `#{@params.name}`", nil, 404
            return

        @m = results[1]
        @app\try_render "lecturer", self

    [apply: "/prijava"]: =>
        @page_id = "apply"
        @m = assert_error content\get "apply"

        @app\try_render "apply", self

    [console: "/console"]: console.make!

    handle_404: =>
        @app.handle_error self, "Route `#{self.req.parsed_url.path or 'unknown'}` not found", nil, 404

