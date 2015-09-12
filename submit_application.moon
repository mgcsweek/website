content = require 'content'
config = (require 'lapis.config').get!
csrf = require 'lapis.csrf'
smtp = require 'resty.smtp'
mime = require 'resty.smtp.mime'
ltn12 = require 'resty.smtp.ltn12'
import to_json from require 'lapis.util'
import decode_with_secret, encode_with_secret from require 'lapis.util.encoding'

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
        
        local class_id
        if not errors.bad_request
            errors.bad_request = true
            i = 0
            for c in *model.form.classes
                i += 1
                if c == params.class
                    errors.bad_request = nil
                    class_id = i
                    break

        with errors
            if not params.firstname or (type params.firstname) != 'string'
                .missing_name = true 
            elseif params.firstname\len! >= 255
                .invalid_name = true 

            if not params.lastname or (type params.lastname) != 'string'
                .missing_name = true
            elseif params.lastname\len! >= 255
                .invalid_name = true
                
            if not params.email or (type params.email) != 'string'
                .missing_email = true 
            elseif params.email\len! >= 255 or not params.email\match "[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?"
                .invalid_email = true 
            
            .task_number_mismatch = true if #tasks < 2

        err_array = { }
        for k, _ in pairs errors
            table.insert err_array, k
        return nil, err_array if #err_array > 0

        prev_app = Applications\find email: params.email
        if prev_app
            return nil, { 'duplicate_application' } if prev_app.submitted == 1
            print "is #{prev_app.email_sent}"
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
            print to_json(application)
            ChosenTasks\create {
                application_id: appid
                task: t
            }

        url = (url_builder '/prijava/upload/') .. encode_with_secret { id: appid }

        local msg
        with model.email
            msg = 
                headers: 
                    to: params.email
                    from: config.smtp_from
                    ['message-id']: 'prijava.' .. appid .. '@csnedelja.mg.edu.rs'
                    subject: mime.ew .subject, nil, { charset: 'utf-8' }
                    ['content-transfer-encoding']: 'BASE64'
                    ['content-type']: 'text/plain; charset=utf-8'

                body: mime.b64 .text\gsub '%%1', url

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

    upload_form: (token) =>
        data = decode_with_secret token
        return nil if not data or not data.id

        appl = Applications\find data.id
        return nil if not appl or appl.is_submitted == 1
        
        appl

