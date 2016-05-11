lapis = require "lapis"
config = (require "lapis.config").get!
content = require "content"
logger = require "lapis.logging"
console = require "lapis.console" if config._name == 'development' or config._name == 'development-perftest'
csrf = require "lapis.csrf"
submit = require "submit_application"
submit_newsletter = require "submit_newsletter"
lfs = require "lfs"

import after_dispatch from require "lapis.nginx.context"
import to_json from require "lapis.util"
import capture_errors, assert_error, yield_error, respond_to from require "lapis.application"
import json_requested from require "utils"

capture_form_errors = (fn) ->
    capture_errors {
        on_error: (err, trace) =>
            err or= @errors
            if @json
                resp = if @m and @m.form and @m.form.responses and @m.form.responses.default
                    @m.form.responses.default
                else
                    '<p>A server error has occurred, and the error text could not be fetched.</p>'

                print to_json err
                { status: 500, json: { response: resp, errors: { } } }
            else
                @app.handle_error self, err, trace, 500

        fn
    }

safe_route = (fn) ->
    capture_errors {
        on_error: =>
            @app.handle_error self, @errors

        =>
            fn self
    }

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

    respond_to_form: (err, model, page_id, template) =>
        resp = { }

        status = if not err
                200
            elseif err[1] == 'internal_error'
                500
            elseif err[1] == 'duplicate_application'
                409
            elseif err[1] == 'too_frequent'
                403
            elseif err[1] == 'file_too_big'
                419
            else
                400

        resp.response = model.form.responses[status] or model.form.responses.default if model.form.responses

        if status == 400
            resp.errors = { }
            for e in *err
                table.insert resp.errors, model.form.validation_errors[e] or 'unknown error' 
        if @json
            { :status, json: resp }
        else
            @resp = resp
            @page_id = page_id
            ret = @app\try_render template, self
            ret.status = status
            ret

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

    [lecturer: "/predavaci/:name"]: safe_route =>
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
        GET: safe_route =>
            print 'hey'
            @page_id = "apply"
            @csrf_token = csrf.generate_token @
            if config.applications_enabled
                @m = assert_error content\get "apply"
                mtime = lfs.attributes 'static/resources/test.pdf', 'modification'
                if mtime
                    @last_updated = os.date '%d.%m.%y. %H:%M', mtime
                @app\try_render "apply", self
            else
                @m = assert_error content\get "apply-newsletter"
                @app\try_render "apply-newsletter", self

        POST: capture_form_errors =>
            @json = json_requested @
            model_name = if config.applications_enabled
                'apply'
            else
                'apply-newsletter'

            model = assert_error content\get model_name
            local succ, ret, err

            @m = model
            if not csrf.validate_token @
                @app.respond_to_form self, { 'bad_token' }, model, model_name, 'apply-result'
            else
                this = self

                if config.applications_enabled
                    succ, ret, err = pcall ->
                        submit\submit this.res.req.params_post, model, (...) ->
                            this\build_url ...
                else
                    succ, ret, err = pcall ->
                        submit_newsletter\submit this.res.req.params_post, model, (...) ->
                            this\build_url ...

                yield_error ret if not succ
                @app.respond_to_form self, err, model, model_name, 'apply-result'
    }

    [apply_upload: "/prijava/upload/*"]: respond_to {
        GET: safe_route =>
            if config.applications_enabled
                @page_id = "apply"
                @m = assert_error content\get "apply-upload"
                @a = assert_error content\get "apply"
                @csrf_token = csrf.generate_token @
                if @application = submit\get_application @params.splat
                    @app\try_render "apply-upload", self
                else
                    redirect_to: '/prijava'
            else
                redirect_to: '/prijava'

        POST: capture_form_errors =>
            if config.applications_enabled
                @json = json_requested @
                model = assert_error content\get 'apply-upload'
                apply_model = assert_error content\get 'apply'
                @m = model

                this = self
                succ, ret, err = pcall ->
                    submit\upload this.res.req.params_post, @params.splat, model, apply_model.tasks

                yield_error ret if not succ

                @app.respond_to_form self, err, model, 'apply', 'apply-result'
            else
                redirect_to: '/prijava'
    }

    [console: "/console"]: console.make!

    [materials: "/materijali"]: safe_route =>
        @page_id = "materials"
        @m = assert_error content\get "materials"
        @app\try_render "materials", self

    handle_404: =>
        @app.handle_error self, "Route `#{self.req.parsed_url.path or 'unknown'}` not found", nil, 404

