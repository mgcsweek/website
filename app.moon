lapis = require "lapis"
config = (require "lapis.config").get!
content = require "content"
logger = require "lapis.logging"
csrf = require "lapis.csrf"
submit = require "submit_application"

import after_dispatch from require "lapis.nginx.context"
import to_json from require "lapis.util"
import capture_errors, assert_error, yield_error, respond_to from require "lapis.application"
import json_requested from require "utils"

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

    [apply: "/prijava"]: respond_to {
        GET: =>
            @page_id = "apply"
            @m = assert_error content\get "apply"
            @csrf_token = csrf.generate_token @
            @app\try_render "apply", self

        POST: capture_errors {
            on_error: (err, trace) =>
                if @json
                    resp = if @m and @m.form and @m.form.responses and @m.form.responses.default
                        @m.form.responses.default
                    else
                        '<p>A server error has occurred, and the error text could not be fetched.</p>'

                    { status: 500, json: { response: resp, errors: { } } }
                else
                    @app.handle_error self, err, trace, 500

            =>
                @json = json_requested @
                model = assert_error content\get "apply"
                @m = model

                this = self
                succ, ret, err = pcall -> submit\submit this.res.req.params_post, model
                print ret
                yield_error ret if not succ

                resp = { }

                status = if ret
                        200
                    elseif err[1] == 'internal_error'
                        500
                    elseif err[1] == 'duplicate_application'
                        409
                    else 
                        400
                
                print 'hi'
                resp.response = model.form.responses[status] or model.form.responses.default
                if status == 400
                    resp.errors = { }
                    for e in *err
                        table.insert resp.errors, model.form.validation_errors[e] or 'unknown error' 
                if @json
                    { :status, json: resp }
                else 
                    @resp = resp
                    @page_id = 'apply'
                    @app\try_render 'apply_result', self
        }
    }

    handle_404: =>
        @app.handle_error self, "Route `#{self.req.parsed_url.path or 'unknown'}` not found", nil, 404

