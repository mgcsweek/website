config = (require 'lapis.config').get!
csrf = require 'lapis.csrf'
smtp = require 'resty.smtp'
mime = require 'resty.smtp.mime'
validation = require 'validation'
import to_json from require 'lapis.util'
import decode_with_secret, encode_with_secret from require 'lapis.util.encoding'
import validate_functions, validate from require 'lapis.validate'

for i in *{ 'is_email', 'has_filetype', 'smaller_than' }
    validate_functions[i] = validation[i]

import Applications, ChosenTasks, Uploads from require 'models'

class SubmitApplication
    submit: (params, model, url_builder) =>
        errors = { }

        tasks = { }
        tasklen = #model.tasks
        local tid
        for k, v in pairs params
            if tid = k\match "^tasks%[(%d+)%]$"
                tid = tonumber tid
                if tid >= 1 and tid <= tasklen
                    table.insert tasks, tid
                else
                    errors.bad_request = true

        ret = validate params, {
                { 'firstname', exists: true, max_length: 255, 'invalid_name' },
                { 'lastname', exists: true, max_length: 255, 'invalid_name' },
                { 'email', exists: true, max_length: 255, is_email: true, 'invalid_email' },
                { 'class', one_of: model.form.classes, 'bad_request' }
            }

        errors.task_number_mismatch = true if #tasks < 2
        if ret
            errors[e] = true for e in *ret

        local class_id
        for i, v in pairs model.form.classes
            class_id = i if v == params.class

        err_array = { }
        for k, _ in pairs errors
            table.insert err_array, k
        return nil, err_array if #err_array > 0

        prev_app = Applications\find email: params.email
        if prev_app
            return nil, { 'duplicate_application' } if prev_app.submitted != 0
            return nil, { 'too_frequent' } if prev_app.email_sent and os.time! - (tonumber prev_app.email_sent) < config.email_cooldown
            prev_app\delete!

        local application, err
        with params
            application, err = Applications\create {
                first_name: .firstname
                last_name: .lastname
                email: .email
                class: class_id
                submitted: 0
            }

        if not application
            print err
            return nil, { 'internal_error' }

        appid = application.id
        for t in *tasks
            ChosenTasks\create {
                application_id: appid
                task: t
            }

        url = (url_builder '/prijava/upload/') .. encode_with_secret { id: appid }

        local msg
        with model.email
            txt = .text\gsub '%%1', url
            txt = mime.b64 txt
            txt = mime.wrp 0, txt
            msg =
                headers:
                    to: params.email
                    from: config.smtp_from
                    ['message-id']: 'MID-application.' .. appid .. '@csnedelja.mg.edu.rs'
                    subject: mime.ew .subject, nil, { charset: 'utf-8' }
                    ['content-transfer-encoding']: 'BASE64'
                    ['content-type']: 'text/plain; charset=utf-8'

                body: txt

        ret, err = smtp.send
            from: config.smtp_username
            rcpt: params.email
            user: config.smtp_username
            password: config.smtp_password
            server: config.smtp_server
            port: config.smtp_port
            source: smtp.message(msg)

        if not ret
            print err
            return nil, { 'internal_error' }

        application\update
            email_sent: os.time!

        true

    get_application: (token) =>
        data = decode_with_secret token
        return nil if not data or not data.id

        appl = Applications\find data.id
        return nil if not appl or appl.submitted != 0

        appl

    store_file: (extension, buf, application_id, context) =>
        upl = Uploads\create { :application_id, :context }
        return nil, 'could not create upload in database' if not upl

        fname = "#{config.uploads_dir}/#{upl.id}.#{extension}"
        f = io.open fname, 'wb'
        return nil, "could not open file `#{fname}`" if not f

        f\write buf
        upl


    upload: (post_params, token, model, tasklist) =>
        appl, _ = SubmitApplication.get_application self, token
        return nil, { 'no_such_application' } if not appl

        validation = {
            { 'pitch', exists: true, 'missing_pitch' }
        }

        import insert from table
        tasks = { }
        for t in *appl\get_chosen_tasks!
            mtask = tasklist[t.task]
            insert tasks, t.task
            insert validation, { "tasks[#{t.task}]", is_file: true, 'invalid_file' }
            insert validation, { "tasks[#{t.task}]", has_filetype: mtask.filetypes, 'invalid_filetype' }
            insert validation, { "tasks[#{t.task}]", smaller_than: config.single_file_limit, 'file_too_big' }

        errs = validate post_params, validation
        if errs
            err_tbl = { }
            err_tbl[e] = true for e in *errs
            if err_tbl.invalid_file
                err_tbl.invalid_filetype = nil
                err_tbl.file_too_big = nil

            return nil, [k for k, _ in pairs err_tbl]

        appl\update { submitted: os.time! }
        for i in *tasks
            f = post_params["tasks[#{i}]"]
            ret = SubmitApplication.store_file self, (validate_functions.has_filetype f, unpack tasklist[i].filetypes), f.content, appl.id, "task #{i}"
            return nil, { 'internal_error' } if not ret

            f.content = nil

        ret = SubmitApplication.store_file self, 'txt', post_params['pitch'], appl.id, "pitch"
        return nil, { 'internal_error' } if not ret

        true
