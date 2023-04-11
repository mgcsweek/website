config = (require 'lapis.config').get!
csrf = require 'lapis.csrf'
mail = require 'resty.mail'
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

        validations = {
                { 'firstname', exists: true, max_length: 255, 'invalid_name' },
                { 'lastname', exists: true, max_length: 255, 'invalid_name' },
                { 'email', exists: true, max_length: 255, is_email: true, 'invalid_email' },
                { 'class', one_of: model.form.classes, 'bad_request' }
            }

        if model.form.all_schools
            table.insert(validations, { 'school', exists: true, 'bad_request' })
        else
            table.insert(validations, { 'school', one_of: model.form.schools, 'bad_request' })

        ret = validate params, validations
        if #model.tasks == 0
            errors.task_number_mismatch = true if #tasks > 0
        else
            errors.task_number_mismatch = true if #tasks < 2

        if ret
            errors[e] = true for e in *ret

        local class_id
        for i, v in pairs model.form.classes
            class_id = i if v == params.class

        local school_id
        if model.form.all_schools
            school_id = params.school
        else
            for i, v in pairs model.form.schools
                school_id = i if v == params.school

        err_array = { }
        for k, _ in pairs errors
            table.insert err_array, k
        return nil, err_array if #err_array > 0

        prev_app = Applications\find email: params.email
        if prev_app
            if config.disable_email_confirmation
                return nil, { 'duplicate_application' }
            else
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
                school: school_id
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

        fn_ret = true
        if not config.disable_email_confirmation
            local msg
            with model.email
                txt = .text\gsub '%%1', url
                msg =
                    from: config.smtp_from
                    to: { params.email }
                    subject: .subject,
                    text: txt

            mailer, err = mail.new
                host: config.smtp_server,
                port: config.smtp_port,
                starttls: true,
                username: config.smtp_username,
                password: config.smtp_password

            if not mailer
                print err
                return nil, { 'internal_error' }

            ret, err = mailer\send msg

            if not ret
                print err
                return nil, { 'internal_error' }
        else
            fn_ret = url

        application\update
            email_sent: os.time!

        fn_ret

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
        f\close!
        upl


    upload: (post_params, token, model, tasklist) =>
        appl, _ = SubmitApplication.get_application self, token
        return nil, { 'no_such_application' } if not appl

        validation = {
            -- { 'pitch', exists: true, 'missing_pitch' }
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

        -- hardcoded for multipitch with 5 pitch fields
        -- TODO write properly
        pitch = ""
        for i = 1, 5
            pitch = pitch .. ">>> Pitanje #{i}" .. "\n" .. post_params["pitch#{i}"] .. "\n\n"

        ret = SubmitApplication.store_file self, 'txt', pitch, appl.id, "pitch"
        return nil, { 'internal_error' } if not ret

        true
